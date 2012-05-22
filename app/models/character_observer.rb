class CharacterObserver < ActiveRecord::Observer
  def after_create(model)
    logger.debug "New Character: #{model.name} from #{model.server}"
  end
end
