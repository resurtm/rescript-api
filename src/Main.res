open Express

let app = express()

@bs.module("body-parser") external bodyParserJson: unit => Middleware.t = "json"
App.use(app, bodyParserJson())

App.get(
  app,
  ~path="/",
  Middleware.from((_, _) => {
    Js.log(Movies.mockedActors)
    Js.log(Movies.mockedMovies)

    let json = Js.Dict.empty()
    Js.Dict.set(json, "success", Js.Json.boolean(true))
    let resp = Js.Json.object_(json)

    Response.sendJson(resp)
  }),
)

App.get(
  app,
  ~path="/movie",
  Middleware.from((_, _) => {
    let items = Js.Array.map((movie: Movies.movie) => {
      let json = Js.Dict.empty()
      Js.Dict.set(json, "id", Js.Json.string(movie.id))
      Js.Dict.set(json, "title", Js.Json.string(movie.title))
      Js.Json.object_(json)
    }, Movies.mockedMovies.contents)
    Response.sendJson(Js.Json.array(items))
  }),
)

let parseJsonMovie = rawJson => {
  switch Js.Json.decodeObject(rawJson) {
  | None => None
  | Some(result) =>
    let movie = {
      Movies.id: Uuid.V4.make(),
      title: Movies.parseJsonStringKey(result, "title"),
      year: Movies.parseJsonNumberKey(result, "year"),
      actors: [],
    }
    if movie.title == "" || movie.year == 0 {
      None
    } else {
      Movies.mockedMovies := Js.Array.concat(Movies.mockedMovies.contents, [movie])
      Some(movie)
    }
  }
}

App.post(
  app,
  ~path="/movie",
  Middleware.from((_, req) => {
    let bodyText = Request.bodyJSON(req)
    switch bodyText {
    | None => Response.sendString("nothing created")
    | Some(x) =>
      switch parseJsonMovie(x) {
      | None => Response.sendString("nothing created")
      | Some(movie) => Response.sendString("movie created with id " ++ movie.id)
      }
    }
  }),
)

let onListen = e =>
  switch e {
  | exception Js.Exn.Error(e) =>
    Js.log(e)
    Node.Process.exit(1)
  | _ => "Listening at http://127.0.0.1:3000"->Js.log
  }

let server = App.listen(app, ~port=3000, ~onListen, ())
