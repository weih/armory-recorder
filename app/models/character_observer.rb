class CharacterObserver < ActiveRecord::Observer
  def after_save(model)
    puts "New Character: #{model.name} from #{model.server}"
  end
end
