module ElmRepoRatio exposing (calculate)

import Types exposing (Repositories, Repository, ElmRepoCalculation)
import Result
import Date
import Time


calculate : Repositories -> ElmRepoCalculation
calculate repos =
    { totalRepositories = totalRepositories repos
    , elmRepositories = elmRepositories repos
    , percentage = percentage (elmRepositories repos) (totalRepositories repos)
    , mostPopularElmRepo = (getMostPopularElmRepo repos)
    , latestElmRepo = (getLatestElmRepo repos)
    }


percentage : Int -> Int -> Float
percentage x y =
    (toFloat x / toFloat y)


totalRepositories : Repositories -> Int
totalRepositories =
    List.length


elmRepositories : Repositories -> Int
elmRepositories =
    List.length << elmRepos


elmRepos : Repositories -> Repositories
elmRepos =
    List.filter (\r -> r.language == Just "Elm")


getMostPopularElmRepo : Repositories -> Maybe Repository
getMostPopularElmRepo repos =
    elmRepos repos
        |> List.sortBy .starCount
        |> List.reverse
        |> List.head


getLatestElmRepo : Repositories -> Maybe Repository
getLatestElmRepo repos =
    elmRepos repos
        |> List.sortBy
            (\repo ->
                Date.fromString repo.pushedAt
                    |> Result.map Date.toTime
                    |> Result.map Time.inMilliseconds
                    |> Result.toMaybe
                    |> Maybe.withDefault 0.0
            )
        |> List.reverse
        |> List.head
