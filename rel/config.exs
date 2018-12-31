Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"$yi$gmFG0mg&ovjx@s[~@wq*0y;~[y`/{;/A`(seYIlQOl)|}U%H=.v~f,>5W6tZ"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"RtW)H1ZRMFB:Wn,}5)]?xpa$/8>v5:Jt4>LQ13mlFt1V7BzTQorK]Vn^sN|)o6uH"
end

release :tiktak do
  set version: current_version(:tiktak)
  set applications: [
        :runtime_tools
      ]
  set commands: [
        migrate: "rel/commands/migrate.sh"
      ]
end

