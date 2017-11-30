# Icon UI Component

## Opts

`classes`, `List`, `@default: []`

`icon`, `String`, `@default: nil, is_required`

If you do not pass an `icon` string to the icon option, you will get an `ArgumentError` in the iex console with directions to resolve the issue.

## Usage

`Sre.UI.Svg.Icon.render_template icon: "check"`

`Sre.UI.Svg.Icon.render_template icon: "check", classes: ["icon--blue", "icon--lg"]`


## Making a new SVG icon

1. make a new file in `web/ui_components/ui/svg/icon` folder
2. name it with this pattern: `<icon name>.html.eex`
3. use this template adding the real svg markup:

```
<svg viewBox="0 0 30 0" version="1.1" xmlns="http://www.w3.org/2000/svg">
  <path d="" fill-rule="evenodd"/>
</svg>
```
