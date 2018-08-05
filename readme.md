# rockstar-ml

rockstar-ml is a Rockstar interpreter implemented in OCaml

## How to build

```sh
make
``` 

or just 

```sh
ocamlbuild -use-menhir rockstar.native
```

## Usage

```
./rockstar.native <options> <files>
Options are:
  -stdin Read script from standard input
  -ast Print the ast rather than eval the script
```

## Demo

Here's the content of `demo.rock`, which is taken from the official spec. 

```
Midnight takes your heart and your soul
While your heart is as high as your soul
Put your heart without your soul into your heart

Give back your heart


Desire is a lovestruck ladykiller
My world is nothing 
Fire is ice
Hate is water
Until my world is Desire,
Build my world up
If Midnight taking my world, Fire is nothing and Midnight taking my world, Hate is nothing
Shout "FizzBuzz!"
Take it to the top

If Midnight taking my world, Fire is nothing
Shout "Fizz!"
Take it to the top

If Midnight taking my world, Hate is nothing
Say "Buzz!"
Take it to the top

Whisper my world
```

Result is shown below.

The abstract syntax tree:
```
# ./rockstar.native -ast demo.rock
Midnight(your heart your soul )
{
  WHILE(((Var: your heart)>=(Var: your soul)))
  {
    your heart=((Var: your heart)-(Var: your soul))
  }
  Return: (Var: your heart)
}
Define: (Var: Desire,100.)
Define: (Var: my world,Null)
Define: (Var: Fire,3.)
Define: (Var: Hate,5.)
UNTIL(((Var: my world)=(Var: Desire)))
{
  Inc: my world
  IF((((Call Midnight:[(Var: my world),(Var: Fire),])=(Val: Null))&&((Call Midnight:[(Var: my world),(Var: Hate),])=(Val: Null))))
  {
    Print: (Val: "FizzBuzz!")
    Continue
  }
  ELSE
  {
    Nop
  }
  IF(((Call Midnight:[(Var: my world),(Var: Fire),])=(Val: Null)))
  {
    Print: (Val: "Fizz!")
    Continue
  }
  ELSE
  {
    Nop
  }
  IF(((Call Midnight:[(Var: my world),(Var: Hate),])=(Val: Null)))
  {
    Print: (Val: "Buzz!")
    Continue
  }
  ELSE
  {
    Nop
  }
  Print: (Var: my world)
}
```

The output of script:
```
# ./rockstar.native demo.rock
1.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.41.42.43.44.45.46.47.48.49.50.51.52.53.54.55.56.57.58.59.60.61.62.63.64.65.66.67.68.69.70.71.72.73.74.75.76.77.78.79.80.81.82.83.84.85.86.87.88.89.90.91.92.93.94.95.96.97.98.99.100.
```