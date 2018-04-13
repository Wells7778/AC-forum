json.data do
  json.array! @posts do |post|
    json.partial! "post", post: post
  end
end