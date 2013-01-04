module PagesHelper

	def links
		x = -1
		current_user.friends.reduce([]) do |links, friend|
			x+=1
			links << {source: 0, target: x} 
		end	
	end		

	def nodes
		current_user.friends.unshift()
	end

	def json_object
		{ nodes: nodes,
		  links: links
		};
	end

end

