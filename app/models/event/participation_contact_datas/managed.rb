
class Event::ParticipationContactDatas::Managed < Event::ParticipationContactData
  self.mandatory_contact_attrs = [:first_name, :last_name]
end
