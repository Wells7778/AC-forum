json.data do
  json.partial! "post", post: @post
  json.partial! "comment", comments: @comments
end