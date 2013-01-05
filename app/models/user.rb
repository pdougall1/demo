class User < ActiveRecord::Base
  attr_accessible :first_name, :image, :last_name, :oauth_expires_at, :oauth_token, :provider, :uid

  def self.from_omniauth(auth)
	  where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
	    user.provider = auth.provider
	    user.uid   = auth.uid
	    user.image = auth.info.image
	    user.first_name  = auth.info.first_name
	    user.last_name   = auth.info.last_name
	    user.oauth_token = auth.credentials.token
	    user.oauth_expires_at = Time.at(auth.credentials.expires_at)
	    user.save!
	  end
	end  

	def facebook
	  @facebook ||= Koala::Facebook::API.new(oauth_token)
	  block_given? ? yield(@facebook) : @facebook
	rescue Koala::Facebook::APIError => e
	  logger.info e.to_s
	  nil
	end

	def facebook_object
		facebook.fql_multiquery({
			"query1" => "SELECT uid, name, pic_square FROM user WHERE (uid = me()) OR (uid IN (select uid2 FROM friend WHERE uid1 = me()))",
		  "query2" => "SELECT originator, snippet, thread_id, subject, recipients FROM thread WHERE folder_id = 0",
			"query3" => "SELECT message, actor_id, comments, likes FROM stream WHERE  filter_key IN (SELECT filter_key FROM stream_filter WHERE uid=me())"
		})
	end	

	def friends
		facebook_object["query1"]
	end
	def messages
		facebook_object["query2"]
	end
	def stream
		facebook_object["query3"]
	end	
end






