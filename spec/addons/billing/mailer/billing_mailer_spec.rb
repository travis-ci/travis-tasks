require 'spec_helper'

describe Travis::Addons::Billing::Mailer::BillingMailer do
  describe '#invoice_payment_succeeded' do
    subject(:mail) { described_class.invoice_payment_succeeded(recipients, subscription, owner, charge, event, invoice, cc_last_digits) }

    let(:recipients) { ['sergio@travis-ci.com'] }
    let(:subscription) {{}}
    let(:owner) {{}}
    let(:invoice) {{ pdf_url: pdf_url, object: {amount_due: 999}, current_period_start: Time.now.to_i, current_period_end: Time.now.to_i, amount: 999, created_at: Time.now.to_s}}
    let(:real_pdf_url) {  'http://invoices.travis-ci.dev/invoices/123'}
    let(:pdf_url) { real_pdf_url }
    let(:filename) { 'TP123.pdf' }
    let(:cc_last_digits) { '1234' }
    let(:charge) { nil}
    let(:event) { nil}

    before do
      stub_request(:get, real_pdf_url).to_return(status: 200, body: "% PDF", headers: {'Content-Disposition' => "attachment; filename=\"#{filename}\""})
    end

    it 'contains the right data' do
      expect(mail.to).to eq(recipients)
      expect(mail.from).to eq(['success@travis-ci.com'])
      expect(mail.subject).to eq('Travis CI: Your Invoice')

      expect(mail.attachments.size).to eq(1)

      attachment = mail.attachments.first

      expect(attachment.content_type).to start_with('application/pdf')
      expect(attachment.filename).to eq(filename)
      expect(attachment.body.raw_source).to start_with('% PDF')
    end

    context 'when the pdf url redirects' do
      let(:pdf_url) { 'http://redirects.dev/'}

      before do
        stub_request(:get, pdf_url).to_return(status: 301, headers: { 'Location' => real_pdf_url})
      end

      it 'still works' do
        expect(mail.attachments.size).to eq(1)

        attachment = mail.attachments.first

        expect(attachment.filename).to eq(filename)
      end
    end
  end
end
