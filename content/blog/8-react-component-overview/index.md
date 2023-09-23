---
title: React.js Functional Component overview
date: "2023-08-27T22:22:00.000Z"
---
In this post we will break down different technical aspects and mechanisms behind `Functional Component`.  

With React 16.8 `Functional Components` were introduced and quickly became de facto status quo. They, however, have to use different mechanisms to accomodate needs as `storage`, `lifecycle stuff` or `events stuff` from `Class Components`. We show some pretty common `React code` with a functional component and explain all stuff that comes into making. 

There are things that come into making of `React` with `Functional Component` code.  

## Code example
```JSX
import React, { useState } from 'react';
import { Pwnspinner } from 'pwnspinner'; // <- 1

interface IBestTeamsProps { // <- for ex. 2
    country: string;
    cnt: number;
}

type Team = {
    name: string;
    wins: number;
    logo: string;
};

function BestTeams(props: IBestTeamsProps = {}) { // <- for ex. 2
    const [teams, setTeams] = useState<Team[]|null>(null); // <- for ex. 2
    const [bestTeam, setBestTeam] = useState<Team|null>(null); // <- 3, for ex. 2
    useEffect(() => {
        let fetchedTeams = await FetchNTeams(cnt); // <- 4 & arbitrary implementation w/ fetch inside
        setTeams(fetchedTeams);
        const bestTeam = teams.find(team => team.wins === Math.max(...teams.map(team => team.wins))); // <- 5(a)
        setBestTeam(bestTeam);
    }, [])

    return ( // <- 6
        <>
            <div>
                <u>{bestTeam.name}</u>
            </div>
            <hr>
            <div>
                {teams.map((team: Team) => <div>{team.wins} {team.name}</div> )} {/* 5(b) */}
            </div>
        </>
    )
}
```

## Breakdown of fundamentals
1. `import` is realized via **JavaScript Modules** [^1].
2. `TypeScript` [^2] is removed during `application build` or `compilation`.
3. `useState` hook[^3] is storing data by Closures [^4] and Destructuring assignment [^5].
4. `fetch` is a browser Web API functionality [^6].
5. Array operations (a)`.find`[^7] and (b)`.map`[^8] are new ES6 features.
6. `JSX` is syntactic sugar for `React.createElement(...)`[^9].


[^1]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules
[^2]: https://www.typescriptlang.org
[^3]: https://react.dev/reference/react/useState
[^4]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Closures
[^5]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Destructuring_assignment
[^6]: https://developer.mozilla.org/en-US/docs/Web/API
[^7]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/find
[^8]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
[^9]: https://react.dev/reference/react/createElement