# Launching test with example-voting-app

The application is totally asynchronous. Therefore, it is very complicated to ask a computation performance. We choose only to test a simple GET on the vote frontend. 

* It could be possible to manage the performances of the application doing the following: sending n votes to the application, and looking how long it takes for the n votes are register in the result frontend. The process seems to be very slow, having small results is maybe difficult, but with an enough big number, it would be doable *

## Launching the test

This test does not reinstall the cluster (the application states does not change during the test, since we only send GET request to the vote frontend)

To launch the test, simply do: 

```bash
./wrk_tput.sh <the_vote_url>
```
Results will be printed in the stdout. 


