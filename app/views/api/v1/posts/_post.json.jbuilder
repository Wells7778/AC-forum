json.catedories post.categories do |category|
  json.name category.name
end
json.(post, :title, :content, :comments_count, :viewed_count)
json.image post.image.current_path
json.author do
  json.name post.user.name
  json.email post.user.email
  json.avatar post.user.avatar.current_path
end