type actorId = string
type actor = {
  id: actorId,
  firstName: string,
  lastName: string,
  birthYear: int,
}

type movieId = string
type movie = {
  id: movieId,
  title: string,
  year: int,
  actors: array<actor>,
}

let mockedActors = ref([
  {id: "200201", firstName: "Ryan", lastName: "Gosling", birthYear: 1980},
  {id: "200202", firstName: "Harrison", lastName: "Ford", birthYear: 1960},
  {id: "200203", firstName: "Carey", lastName: "Mulligan", birthYear: 1980},
])

let mockedMovies = ref([
  {
    id: "100100",
    title: "Blade Runner",
    year: 2018,
    actors: [mockedActors.contents[0], mockedActors.contents[1]],
  },
  {
    id: "100101",
    title: "Drive",
    year: 2011,
    actors: [mockedActors.contents[1], mockedActors.contents[2]],
  },
])

let parseJsonStringKey = (rawJson, keyName) => {
  switch Js.Dict.get(rawJson, keyName) {
  | None => ""
  | Some(value) =>
    switch Js.Json.decodeString(value) {
    | None => ""
    | Some(value) => value
    }
  }
}

let parseJsonNumberKey = (rawJson, keyName) => {
  switch Js.Dict.get(rawJson, keyName) {
  | None => 0
  | Some(value) =>
    switch Js.Json.decodeNumber(value) {
    | None => 0
    | Some(value) => int_of_float(value)
    }
  }
}
