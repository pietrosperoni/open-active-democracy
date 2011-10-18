class RemoteLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
 private

 def link(text, target, attributes = {})
   attributes[:href] = target
   attributes['data-remote'] = 'true'
   tag(:a, text, attributes)
 end
end