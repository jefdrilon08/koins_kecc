require "rails_helper"

feature "Navigation" do
  let!(:current_user) { create_logged_in_user }

  before do
    visit "/"
  end

  xscenario "viewing root" do
    within ".sidebar" do
      click_link "Dashboard"
    end

    expect(page).to have_content "#{current_user.username}-1"
    expect(current_path).to eq "/app/network"
  end
end
