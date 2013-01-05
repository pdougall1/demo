module PagesHelper

	def links
		x = -1
		comment_count = count_instances_in(stream_cleaned_for_counting, :comments)
		actor_count = count_instances_in(stream_cleaned_for_counting, :actor_id)
		originator_count = count_instances_in(messages_cleaned_for_counting, :originator)
		recipients_count = count_instances_in(messages_cleaned_for_counting, :recipients)
		links_array = current_user.friends.reduce([]) do |links, friend|
			x+=1
			links_hash = {source: 0, target: x}
			links_hash[:affiliation] = comment_count[friend['uid']] + actor_count[friend['uid']] + originator_count[friend['uid']] + recipients_count[friend['uid']]
			links << links_hash 
		end		
		links_array.shift
		links_array
	end		

	def nodes
		current_user.friends
	end

	def facebook_object
		{ nodes: nodes,
		  links: links
		};
	end

	def stream_cleaned_for_counting
		posts = current_user.stream
		posts.reduce([]) do |new_array, post|
			post_hash = {}
			post_hash[:actor_id] = post['actor_id']
			post_hash[:comments] = post['comments']['comment_list'].reduce([]) do |comment_array, comment|
				comment_array << comment['fromid']
			end	
			new_array << post_hash
		end	
	end

	def messages_cleaned_for_counting
		messages = current_user.messages
		messages.reduce([]) do |new_array, message|
			message_hash = {}
			message_hash[:originator] = message['originator']
			message_hash[:recipients] = message['recipients']
			new_array << message_hash
		end	
	end

	def count_instances_in(array, symbol)
		new_array = array.map {|s| s[symbol]}.flatten
		new_array.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}
	end
end





