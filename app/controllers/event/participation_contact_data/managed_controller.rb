
class Event::ParticipationContactData::ManagedController < Event::ParticipationContactDatasController
  def person
    @person ||= Person.new.tap do |person|
      person.managers = [current_user]
    end
  end

  def contact_data_class
    Event::ParticipationContactDatas::Managed
  end
end
