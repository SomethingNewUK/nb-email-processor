def point_people
  $point_people ||= YAML.load_file('point_people.yml')
end

def assign(nb, text, id)

  person = nil
  name = nil
  point_people.each_pair do |key, array|
    array.each do |value|
      if text.match value
        person = key
        name = value
      end
    end
  end
  if person
    puts "Reassigning user #{id} to #{name}"
    nb.call(:people, :update, id: id.to_i, person: { parent_id: person.to_i })
  end

end