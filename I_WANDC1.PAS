const
   WANDERMAX = 224; {must be multiple of 32}

type
    wander_record =
      record
        x:byte;
        y:byte;
        xin:byte;
        yin:byte;
        creature:byte;
        creatureparam:byte;
        odds:byte;
      end;

    wander_index_32 = array[1..32] of wander_record;
    wander_index_type = array[1..WANDERMAX] of wander_record;
var
    wander_index: ^wander_index_type;



