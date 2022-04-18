# Rails6 ECS template

Evolved from [rails6_template](https://github.com/Iwark/rails6_template).

It generates a rails project with:

- Ruby 3.0.2
- Rails 6.1.4
- [tailwind](https://tailwindcss.com/)
- [slim template](http://slim-lang.com/)
- [sidekiq](https://github.com/mperham/sidekiq) with Redis
- [Sentry](https://sentry.io/)

It assumes you're using [vscode](https://code.visualstudio.com/) as your editor thus it adds `.vscode/settings.json` for you.

## How to make a rails project with this template

```
$ rails new project_name -m https://raw.githubusercontent.com/Iwark/rails6_ecs_template/master/app_template.rb
```

add `sentry_dsn` to credentials if you want to use Sentry.

```
$ rails credentials:edit
```
