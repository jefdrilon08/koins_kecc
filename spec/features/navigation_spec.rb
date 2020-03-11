require "rails_helper"

feature "[Navigation]" do
  let!(:current_user) { create_logged_in_user }

  before do
    visit "/"
  end

  scenario "home page" do
    expect(page).to have_content current_user.username
    expect(current_path).to eq "/"

    within ".sidebar" do
      click_link "Dashboard"
    end

    expect(page).to have_content current_user.username
    expect(current_path).to eq "/"
  end

  [
    "Repayment Rates",
    "Manual Aging",
    "Personal Funds",
    "Loan Stats",
    "Member Counts",
    "Voucher Summary",
    "SOA Expenses",
    "SOA Loans",
    "SOA Funds",
    "Watchlists",
    "Monthly New/Res.",
    "Monthly Incentives",
    "X Weeks to Pay",
    "Branch Resignations",
  ].each do |link_text|
    feature "Sidebar - '#{link_text}'" do
      before do
        within(".sidebar") { click_link link_text }
      end

      scenario "index page" do
        expect(page).to have_content link_text
      end
    end
  end
end
