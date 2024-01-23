# Rails7 ECS template

It generates a rails project with:

- Ruby 3.2.3
- Rails 7.1
- Postgres 15
- Redis 7.0
- Cuprite Testing (chrome)
- [tailwind](https://tailwindcss.com/)
- [sidekiq](https://github.com/mperham/sidekiq) with Redis
- [Sentry](https://sentry.io/)

It assumes you're using [vscode](https://code.visualstudio.com/) as your editor thus it adds `.vscode/settings.json` for you.

## How to make a rails project with this template

```
$ rails new project_name -m https://raw.githubusercontent.com/Iwark/rails7_ecs_template/main/app_template.rb
```

add `sentry_dsn` to credentials if you want to use Sentry.

```
$ rails credentials:edit
```
