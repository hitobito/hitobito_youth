# frozen_string_literal: true

#  Copyright (c) 2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.
require "spec_helper"

describe InvoiceMailer do
  let(:invoice) { invoices(:invoice) }
  let(:sender) { people(:bottom_member) }
  let(:mail) { InvoiceMailer.notification(invoice, sender) }
  let(:recipient) { invoice.recipient }

  subject { mail }

  context "without managers" do
    its(:cc) { should be_empty }
  end

  context "with manager" do
    let(:manager) { people(:bottom_leader) }

    before do
      recipient.managers << manager
      recipient.save!
    end

    its(:cc) { should == [manager.email] }

    context "with invoice email" do
      before do
        manager.additional_emails.create!(email: "invoices@example.com", label: "Privat", invoices: true)
      end

      its(:cc) { should == ["invoices@example.com"] }
    end
  end

  context "for external invoice" do
    before do
      invoice.update!(recipient: nil)
    end

    its(:cc) { should be_empty }
  end
end
