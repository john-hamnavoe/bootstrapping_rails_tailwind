=begin
Template Name: Hamnavoe - Tailwind CSS
Author: Andy Leverenz/John H Wallace (for my needs)
Author URI: https://web-crunch.com
Instructions: $ rails new myapp -d <postgresql, mysql, sqlite3> -m template.rb
=end

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem 'devise', '~> 4.7', '>= 4.7.3'
  gem 'devise_invitable', '~> 2.0.0'
  gem 'font-awesome-sass', '~> 5.15.1'
  gem 'friendly_id', '~> 5.4', '>= 5.4.1'
  gem 'noticed', '~> 1.2', '>= 1.2.21'
  gem 'pagy', '~> 3.8', '>= 3.8.3'
  gem 'redis', '~> 4.2', '>= 4.2.2'
  gem 'sidekiq', '~> 6.1', '>= 6.1.2'
  gem 'name_of_person', '~> 1.1', '>= 1.1.1'

  gem_group :development, :test do
    # test emails
    gem "letter_opener"

    # lint
    gem "rubocop", "0.82.0"
    gem "rubocop-github", "0.16.0"
    gem "rubocop-performance", "1.7.0", require: false
    gem "rubocop-rails", "2.6.0", require: false  
  end
end

def add_users
  # Install Devise
  generate "devise:install"

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
              env: 'development'

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, "User", "first_name", "last_name", "admin:boolean"

  # set admin boolean to false by default
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  # name_of_person gem
  append_to_file("app/models/user.rb", "\n  has_person_name\n", after: "class User < ApplicationRecord")
  append_to_file("app/models/user.rb", "\n  has_many :organisation_memberships, dependent: :restrict_with_error\n", after: "class User < ApplicationRecord")
  append_to_file("app/models/user.rb", "\n  has_many :notifications, as: :recipient\n", after: "class User < ApplicationRecord")
  append_to_file("app/models/user.rb", "\n  belongs_to :current_organisation, class_name: \"Organisation\", optional: true\n", after: "class User < ApplicationRecord")

  # devise invitable 
  generate "devise_invitable:install"
  generate "devise_invitable User"
  # seems to be necessary
  append_to_file("app/models/user.rb", " :invitable,", after: "devise")
  insert_into_file "config/routes.rb", ', controllers: { invitations: "users/invitations" }', after: "  devise_for :users"
end

def copy_templates
  directory "app", force: true
  # sometimes in VS the tailwind intellsense was picking up the tailwind.config.js here and not finding tailwind css it did not install
  # so file has been renamed in template and we set up this way so it does not clash with the intellesense
  copy_file "app/javascript/stylesheets/tailwind.config.js.erb", "./app/javascript/stylesheets/tailwind.config.js"
  remove_file "app/javascript/stylesheets/tailwind.config.js.erb"

  copy_file ".rubocop.yml"
end

def add_tailwind
  # Until PostCSS 8 ships with Webpacker/Rails we need to run this compatability version
  # See: https://tailwindcss.com/docs/installation#post-css-7-compatibility-build
  run "yarn add tailwindcss@npm:@tailwindcss/postcss7-compat postcss@^7 autoprefixer@^9"
  run "mkdir -p app/javascript/stylesheets"

  append_to_file("app/javascript/packs/application.js", 'import "stylesheets/application"')
  inject_into_file("./postcss.config.js", "\n    require('tailwindcss')('./app/javascript/stylesheets/tailwind.config.js'),", after: "plugins: [")

  run "mkdir -p app/javascript/stylesheets/components"
end

# Remove Application CSS
def remove_app_css
  remove_file "app/assets/stylesheets/application.css"
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n",
    before: "Rails.application.routes.draw do"

  content = <<-RUBY
    authenticate :user, lambda { |u| u.admin? } do
      mount Sidekiq::Web => '/sidekiq'
    end
  RUBY
  insert_into_file "config/routes.rb", "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_foreman
  copy_file "Procfile"
  copy_file "Procfile.dev"
end

def add_friendly_id
  generate "friendly_id"
end

def add_notifications
  generate "noticed:model"

  route "resources :notifications, only: [:index]"
  route "resources :notification_all_as_reads, only: [:create]"
end

def add_organisations
  generate :model, "organisation", "name:string", "owner:references", "domain:string", "restrict_to_domain:boolean", "active:boolean"
  # set fk table correctly on owner
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /foreign_key: true/, "foreign_key: { to_table: :users }"
    gsub_file migration, /:active/, ":active, default: true"
    gsub_file migration, /:restrict_to_domain/, ":restrict_to_domain, default: true"
  end
  append_to_file("app/models/organisation.rb", "\n  has_one_attached :logo\n", after: "belongs_to :owner")
  append_to_file("app/models/organisation.rb", ", class_name: \"User\"", after: "belongs_to :owner")

  generate :migration, "AddCurrentOrganisationToUsers", "current_organisation:references"
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /null: false, foreign_key: true/, "null: true, foreign_key: { to_table: :organisations }"
  end

  generate :model, "organisation_membership", "organisation:references", "user:references", "is_admin:boolean"
  route "resources :organisations, only: [:new, :edit, :update, :create]"
  route "resources :organisation_memberships, only: [:destroy, :index, :create, :update]"

  append_to_file("app/models/organisation.rb", "\n  has_many :organisation_memberships, dependent: :restrict_with_error\n", after: "belongs_to :owner, class_name: \"User\"")
end

def add_stimulus_and_reflex
  gem 'stimulus_reflex', '~> 3.4'
  rails_command "webpacker:install:stimulus"
  rails_command "stimulus_reflex:install"

  # put our application_reflex.rb in after the stimulus install
  remove_file "app/reflexes/application_reflex.rb"
  copy_file "app/reflexes/application_reflex.rb.erb", "./app/reflexes/application_reflex.rb"
  remove_file "app/reflexes/application_reflex.rb.erb"

  run "yarn add tailwindcss-stimulus-components"

  append_to_file("app/javascript/controllers/index.js", "\nimport { Dropdown, Modal, Tabs, Popover, Toggle, Slideover } from \"tailwindcss-stimulus-components\"")
  append_to_file("app/javascript/controllers/index.js", "\napplication.register('dropdown', Dropdown)")
  append_to_file("app/javascript/controllers/index.js", "\napplication.register('modal', Modal)")
  append_to_file("app/javascript/controllers/index.js", "\napplication.register('tabs', Tabs)")
  append_to_file("app/javascript/controllers/index.js", "\napplication.register('popover', Popover)")
  append_to_file("app/javascript/controllers/index.js", "\napplication.register('toggle', Toggle)")
  append_to_file("app/javascript/controllers/index.js", "\napplication.register('slideover', Slideover)")

  run "yarn add debounced"
  inject_into_file("app/javascript/controllers/index.js", "\nimport debounced from 'debounced' \n\ndebounced.initialize()", after: "import controller from '../controllers/application_controller'")

  run "yarn add sortablejs"

  copy_file "drag_controller.js", "./app/javascript/controllers/drag_controller.js"
end

def add_grid_columns
  generate :model, "grid", "name:string", "label:string"
  generate :model, "column", "name:string", "label:string", "sortable:boolean", "default_on:boolean", "default_position:integer", "field:string", "object_1:string", "object_2:string", "grid:references"
  generate :model, "grid_view", "name:string", "grid:references", "user:references"
  generate :model, "grid_view_column", "grid_view:references", "column:references", "label:string", "position:integer"

  route "resources :grid_views, only: [:index]"

  content = <<-RUBY
    resources :users, only: [:index] do
      resources :grid_views, only: [:index, :create, :edit, :destroy]
      resources :grid_view_columns, only: [:create, :destroy] do
        member do
          patch :move
        end
      end
    end
  RUBY
  insert_into_file "config/routes.rb", "#{content}\n\n", after: "root to: 'home#index'\n"
end

def add_dashboard
  generate :model, "dashboard_metric", "name:string", "title:string", "icon:string", "color:string", "position:integer"
  generate :model, "dashboard_metric_snapshot", "organisation:references", "dashboard_metric:references", "date:date", "value:integer", "last_value:integer"
  route "resources :dashboard, only: [:index]"
end

# Main setup
source_paths

add_gems

after_bundle do
  add_users
  remove_app_css
  add_sidekiq
  add_foreman
  copy_templates
  add_tailwind
  add_friendly_id
  add_notifications
  add_organisations
  add_stimulus_and_reflex
  add_grid_columns
  add_dashboard

  rails_command "active_storage:install"
  
  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"

  git :init
  git add: "."
  git commit: %Q{ -m "Initial commit" }

  say
  say "Hamnavoe app successfully created! 👍", :green
  say
  say "Switch to your app by running:"
  say "$ cd #{app_name}", :yellow
  say
  say "Then run:"
  say "$ foreman start -f Procfile.dev", :green
end
