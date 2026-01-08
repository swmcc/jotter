# Jotter - AI Agent Workflow Instructions

## Quick Reference Commands

| Task | Command |
|------|---------|
| Run tests | `bundle exec rspec` |
| Run single test | `bundle exec rspec spec/path/to/spec.rb` |
| Lint | `bundle exec rubocop` |
| Lint fix | `bundle exec rubocop -A` |
| Security scan | `bin/brakeman --no-pager` |
| Dev server | `bin/dev` |
| Console | `rails console` |
| Migrations | `rails db:migrate` |
| Reset DB | `rails db:reset` |

## Key Files

| Category | Files |
|----------|-------|
| **Routes** | `config/routes.rb` |
| **Models** | `app/models/bookmark.rb`, `app/models/photo.rb`, `app/models/gallery.rb`, `app/models/album.rb`, `app/models/user.rb`, `app/models/tag.rb`, `app/models/tagging.rb` |
| **Controllers** | `app/controllers/bookmarks_controller.rb`, `app/controllers/photos_controller.rb`, `app/controllers/galleries_controller.rb`, `app/controllers/albums_controller.rb`, `app/controllers/short_urls_controller.rb`, `app/controllers/uploads_controller.rb` |
| **Authentication** | `app/controllers/concerns/authentication.rb`, `app/controllers/sessions_controller.rb`, `app/models/session.rb`, `app/models/current.rb` |
| **Database Schema** | `db/schema.rb` |
| **Tests** | `spec/` directory |
| **CI Pipeline** | `.github/workflows/ci.yml` |
| **Deployment** | `config/deploy.yml`, `Dockerfile` |

## Implementation Guidelines

### Before Making Changes

1. **Read the relevant spec files** in `openspec/specs/` to understand requirements
2. **Check existing tests** in `spec/` for current behaviour
3. **Review the model** for validations, associations, and callbacks
4. **Check the controller** for authorisation and response formats

### When Implementing Features

1. **Start with the model** - add validations, associations, and business logic
2. **Update the database** - create migrations for schema changes
3. **Implement controller actions** - follow RESTful conventions
4. **Add views** - use Tailwind CSS and Turbo
5. **Write tests** - model specs, then request specs

### Testing Requirements

- All models MUST have corresponding specs
- Request specs SHOULD cover happy path and error cases
- Run `bundle exec rspec` before committing
- Run `bundle exec rubocop` to ensure style compliance
- Run `bin/brakeman --no-pager` for security checks

### Code Style

- Follow RuboCop Rails Omakase conventions
- Use 2-space indentation
- Prefer explicit returns in multi-line methods
- Use guard clauses for early returns
- Prefer `&&` and `||` over `and` and `or`

## Common Tasks

### Adding a New Feature to Bookmarks

1. Read `openspec/specs/bookmarks/spec.md` for requirements
2. Check `app/models/bookmark.rb` for existing structure
3. Add migration if database changes needed
4. Update model with new validations/methods
5. Add controller actions in `app/controllers/bookmarks_controller.rb`
6. Create/update views in `app/views/bookmarks/`
7. Write specs in `spec/models/bookmark_spec.rb` and `spec/requests/bookmarks_spec.rb`
8. Run full test suite

### Adding a New Feature to Photos

1. Read `openspec/specs/photos/spec.md` for requirements
2. Check `app/models/photo.rb` for existing structure
3. Consider Active Storage requirements for image handling
4. Add background job if processing needed (`app/jobs/process_photo_job.rb`)
5. Update controller and views
6. Write specs

### Modifying Short URLs

1. Check `app/controllers/short_urls_controller.rb`
2. Ensure collision detection in model's `generate_short_code` method
3. Update routes in `config/routes.rb` if needed
4. Test redirect behaviour

### Adding Tags to Content

1. Tags use polymorphic `Tagging` association
2. Add `has_many :taggings, as: :taggable` to model
3. Implement `tag_list` and `tag_list=` methods
4. Tags are normalised to lowercase

### Authentication Patterns

- Use `allow_unauthenticated_access only: [:action]` for public endpoints
- Use `require_authentication` in `before_action` for protected endpoints
- Access current user via `Current.session.user`
- Check authentication with `authenticated?` helper

## Workflow Checklist

### Before Committing

- [ ] Tests pass: `bundle exec rspec`
- [ ] Linting passes: `bundle exec rubocop`
- [ ] No security issues: `bin/brakeman --no-pager`
- [ ] Migrations run cleanly
- [ ] Manual testing of key user flows

### For Pull Requests

- [ ] All CI checks pass
- [ ] Tests cover new functionality
- [ ] No new RuboCop warnings
- [ ] Commit messages use gitmoji format
- [ ] Documentation updated if needed

## Error Handling Patterns

### Controllers

```ruby
# Redirect with alert for not found
redirect_to collection_path, alert: "Not found"

# Render with unprocessable_entity for validation errors
render :new, status: :unprocessable_entity

# Support multiple formats
respond_to do |format|
  format.html { redirect_to ... }
  format.json { render json: { errors: ... }, status: :unprocessable_entity }
end
```

### Models

```ruby
# Custom validation
validate :custom_validation_method

def custom_validation_method
  errors.add(:field, "must be valid") unless condition
end
```

## Background Jobs

Photo processing uses `ProcessPhotoJob` to generate image variants:

```ruby
ProcessPhotoJob.perform_later(@photo.id)
```

Jobs use Solid Queue - check `config/queue.yml` for configuration.

## API Token Authentication

The application supports API tokens for programmatic access:
- Tokens are managed via `/api_tokens`
- Store tokens securely (shown only once on creation)
- Include token in requests via header or parameter
