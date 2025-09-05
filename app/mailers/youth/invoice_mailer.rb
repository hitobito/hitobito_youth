#  Copyright (c) 2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

module Youth::InvoiceMailer
  extend ActiveSupport::Concern

  def mail(headers = {}, &block)
    cc = headers[:cc] || []
    cc |= manager_emails(except: [@invoice.recipient_email])
    super(headers.merge({cc: cc}), &block)
  end

  private

  def manager_emails(except: [])
    return [] if @invoice.recipient.blank?
    @invoice.recipient.managers.to_a
      .map { |manager| invoice_email(manager) }
      .compact
      .reject { |email| except.include?(email) }
  end

  def invoice_email(person)
    person.additional_emails.find(&:invoices?)&.email || person.email
  end
end
