module TestFeatureHelpers
  include Warden::Test::Helpers

  def create_logged_in_user(user = nil)
    user ||= create(:user)
    login_as user, scope: :user
    user
  end

  def create_logged_in_admin_user(admin_user = nil)
    admin_user ||= create(:admin_user)
    login_as admin_user, scope: :admin_user
    admin_user
  end

  def expect_flash(text)
    expect(page).to have_css(".FlashMessages", text: text)
  end

  def expect_admin_flash(text)
    expect(page).to have_css(".flashes", text: text)
  end
end
