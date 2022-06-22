# BeforeInstall routine
git pull origin develop
bundle install
rails db:migrate
yarn build
