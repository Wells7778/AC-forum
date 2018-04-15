json.comments comments do |comment|
  json.content comment.content
  json.comment_author do
    json.name comment.user.name
    json.email comment.user.email
    json.avatar comment.user.avatar.url
  end
end