# gitmoji-dart
<a href="https://gitmoji.dev">
  <img
    src="https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg?style=flat-square"
    alt="Gitmoji"
  />
</a>

This is a Dart implementation of the [gitmoji-cli](https://github.com/carloscuesta/gitmoji-cli).

## 🤔 Why?
Because I had nothing better to do. \
Jokes aside: Although there is the existing gitmoji-cli npm package, I decided to reimplement it in Dart to provide a lightweight and self-contained solution for my Dart and Flutter projects. By avoiding the reliance on the (globally) installed npm package, other developers can easily commit their changes in style without any external dependencies.

## 📥 Install
To use this CLI tool, you need to add the gitmoji package to your pubspec.yaml file. However, since a package with the same name already exists on pub.dev, you will need to manually add the package from this GitHub repository as a dev-dependency instead of being able to conveniently install it using the dart cli. 🥲

Add it as a dev-depenency to your project
```yaml
dev_dependencies:
  gitmoji:
    git:
      url: https://github.com/gthvmt/gitmoji-dart.git
```
Note that in the future, I may rename this package to *gitmoji_dart* to avoid conflicts with the existing *gitmoji* package and publish it to pub.dev. However, this will mean that you have to run the package with `dart run gitmoji_dart`.

<!-- The following is only relevant once the package was published to pub.dev:
or install it globaly \
`dart pub global activate gitmoji_dart`
-->
## 📝 Usage
<!-- The following is only relevant once the package was published to pub.dev:
If you installed this package globally you can ommit the ``dart run`` infront of the commands\ -->
`dart run gitmoji --help`
```
A dart implementation of gitmoji-cli

Usage: gitmoji <command> [arguments]

Global options:
-h, --help    Print this usage information.

Available commands:
  commit   Interactively commit using the prompts
```

### Commit
#### Client
Start the interactive commit client, to auto generate your commit based on your prompts. \
`dart run gitmoji commit`

##### Options
You can pass default values to the prompts using the following flags:
- `title`: For setting the commit title.
- `message`: For setting the commit message.
- `scope`: For setting the commit scope.

Those flags can be used like this:\
`dart run gitmoji commit -t="Commit" -m="Message" -s="Scope"`

#### Hook
Run the init option, add your changes and commit them, after that the prompts will begin and your commit message will be built.
```bash
dart run gitmoji init
git add .
git commit
```
`gitmoji init` also installs an alias `git cm` which will let you commit your changes without the option to edit the commit message after it has been generated (which can also be archieved by appending `--no-edit` to `git commit`).

## ⚠️ Disclaimer
Missing a lot of features currently. Basically all besides being able to commit. Also the commit cli sometimes bugs out (at least for me using the windows terminal). If that happens to you simply clear the console and try again. 👍