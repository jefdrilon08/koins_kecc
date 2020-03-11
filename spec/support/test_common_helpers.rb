module TestCommonHelpers
  def append_and_fund(position, parent, registration, user)
    Commands::AppendAndFund.new(
      parent:       parent,
      position:     position == :lft ? Genealogy::LFT : Genealogy::RGT,
      registration: registration,
      user:         user,
    ).run
  end

  def create_logged_in_admin_user(admin_user = nil)
    admin_user ||= create(:admin_user)
    login_as admin_user, scope: :admin_user
    admin_user
  end

  def allow_slack_target(method, target_class)
    allow_any_instance_of(Commands::NotifySlack)
      .to receive(method)
      .with(kind_of(target_class))
  end

  def expect_slack_target(method, target_class)
    expect_any_instance_of(Commands::NotifySlack)
      .to receive(method)
      .with(kind_of(target_class))
  end

  def kyc_approve!(user)
    user.update_column(:unconfirmed_mobile_number, FFaker::PhoneNumber.phone_number)
    create(:document, :scan, :approved, user: user)
    create(:document, :selfie, :approved, user: user)
  end
end
