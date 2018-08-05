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

```
# ./rockstar.native -ast demo.rock
Midnight(your heart your soul )
{
  WHILE(((Var: your heart)>=(Var: your soul)))
  {
    your heart=((Var: your heart)-(Var: your soul))
  }
  {
    Return: (Var: your heart)
  }
}
{
  Define: (Var: Desire,3.)
  Define: (Var: my world,Null)
  Define: (Var: Fire,100.)
  Define: (Var: Hate,5.)
  {
    UNTIL(((Var: my world)=(Var: Desire)))
    {
      Inc: my world
      {
        IF(((Val: 1.)=(Val: 1.)))
        {
          Print: (Val: "FizzBuzz!")
          Continue
        }
        {
          Nop
        }
        {
          IF(((Call Midnight:[(Var: my world),(Var: Fire),])=(Val: Null)))
          {
            Print: (Val: "Fizz!")
            Continue
          }
          {
            Nop
          }
          {
            IF(((Call Midnight:[(Var: my world),(Var: Hate),])=(Val: Null)))
            {
              Print: (Val: "Buzz!")
              Continue
            }
            {
              Nop
            }
            {
              Print: (Var: my world)
            }
          }
        }
      }
    }
  }
}

# ./rockstar.native demo.rock
FizzBuzz!FizzBuzz!FizzBuzz!⏎
```