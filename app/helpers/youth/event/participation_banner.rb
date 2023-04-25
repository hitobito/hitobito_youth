module Youth::Event::ParticipationBanner

  def status_text
    if waiting_list?
      key = 'waiting_list'
    elsif pending?
      key = 'pending'
    else
      key = 'explanation'
    end

    key = ['managed', key].join('.') unless @user_participation.person == @context.current_user

    t("event.participations.cancel_application.#{key}", person: @user_participation.person.full_name)
  end
end
