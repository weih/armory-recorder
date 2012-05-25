class CharacterObserver < ActiveRecord::Observer
  def after_save(model)
    puts "New Character: #{model.name} from #{model.server}"
    if model.created_at.to_date == Date.today.to_date
     CharacterMailer.delay.new_record(model)
    else
      puts "Fresh Old Character."
    end
  end
end
