def taggings
  $taggings ||= YAML.load_file('tags.yml')
end

def apply_tags(nb, text, id, tags)

  tags = []
  taggings.each_pair do |key, value|
    if body.match value
      tags << key
    end
  end
  unless tags.empty?
    puts "Tagging user #{id} with #{tags.inspect}"
    nb.call(:people, :tag_person, id: id.to_i, tagging: { tag: tags })
  end

end