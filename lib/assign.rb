def point_people
  $point_people ||= YAML.load_file('point_people.yml')
end

def assign(nb, text, id)

  person = nil
  point_people.each_pair do |key, value|
    if text.match value
      person = key
    end
  end
  if person
    puts "Reassigning user #{id} to #{person}"
    nb.call(:people, :update, id: id.to_i, person: { parent_id: person.to_i })
  end

end