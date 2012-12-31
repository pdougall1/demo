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

	def friends_count
	  facebook { |fb| fb.get_connection("me", "friends").size }
	end

	def friends_list
	  facebook { |fb| fb.get_connection("me", "friends") }
	end	

	def friends_with_details
		object = facebook.fql_query("select uid, name, pic_square from user where uid in (select uid2 from friend where uid1 = me())")
	end 
end
