const default_speed = 20
const default_period = 1
const default_batch = 1

const default_drop_len = 30
const default_tip_len = 1
const default_tail_len = 10

const default_tip_clr = (ansi wb)
const default_drop_clr = (ansi gb)
const default_tail_clr = (ansi g)
const default_bg_clr = (ansi reset)

const default_chars = 'abcdefghijklmnopqrstuvwxyz0123456789'

def validate-ansi-color [clr: string, span: record] {
  if ($clr | find -r $'(ansi escape)\[[\d;]+m$' | is-empty) {
    error make {
      msg: "Bad color supplied",
      label: {text: 'this is not a valid ANSI color code', span: $span}
    }
  }
  $clr
}

def random-char [chars: list<string>] {
  $chars | get (random int 0..<($chars | length))
}

def "droplet empty" [] {
  droplet new 0 0 0
}

def "droplet new" [len: int, tip: int, tail: int] {
  {
    cur_len: $len
    tip_end: ($len - $tip)
    tail_start: $tail
  }
}

def simple-rain-loop [
  speed: int
  period: int
  batch: int
  drop_len: int
  tip_len: int
  tail_len: int
  drop_clr: string
  tip_clr: string
  tail_clr: string
  bg_clr: string
  chars: list<string>
]: nothing -> nothing {
  let delay = 1sec / $speed

  mut cols = (term size).columns
  mut drop_data = 0..<$cols | each { droplet empty }
  mut drop_period_cntr = 1
  
  try {
    print -n (ansi cursor_off)
    print -n $bg_clr
    print -n (ansi cls)

    loop {
      # handle terminal resize
      let new_cols = (term size).columns
      if $cols != $new_cols {
        let dif = $cols - $new_cols | math abs
        if $cols < $new_cols {
          $drop_data = $drop_data | append (0..<$dif | each { droplet empty })
        } else {
          $drop_data = $drop_data | drop $dif
        }
        $cols = $new_cols
      }

      # randomly spawn a batch of drops on period counter reaching 0
      $drop_period_cntr -= 1
      if $drop_period_cntr == 0 {
        $drop_period_cntr = $period
        mut empty_indices = $drop_data
          | enumerate
          | where item.cur_len == 0
          | get index
        mut batch_cnt = $batch
        while $batch_cnt > 0 and ($empty_indices | is-not-empty) {
          $batch_cnt -= 1
          let i = random int 0..<($empty_indices | length)
          let idx = $empty_indices | get $i
          $empty_indices = $empty_indices | drop nth $i
          $drop_data = $drop_data
            | update $idx (droplet new $drop_len $tip_len $tail_len)
        }
      }

      # form a string from droplet data
      let str = $drop_data
      | each {
        if $in.cur_len == 0 {
          ' '
        } else {
          let clr = if $in.cur_len > $in.tip_end {
            $tip_clr
          } else if $in.cur_len <= $in.tail_start {
            $tail_clr
          } else {
            $drop_clr
          }
          $'($clr)(random-char $chars)(ansi reset)($bg_clr)'
        }
      }
      | str join

      # decrement lengths of drops
      $drop_data = $drop_data | update cur_len {
        if $in > 0 {
          $in - 1
        } else {
          0
        }
      }

      # print formed string at the top of the terminal
      print $"(ansi -e 'T')(ansi home)($str)"

      sleep $delay
    }
  }

  print -n (ansi cursor_on)
  print -n (ansi reset)
  print -n (ansi cls)
}

# A simple digital rain animation.
export def simple [
  --speed: int = $default_speed # Animation speed in lines/sec. (min: 1)
  --period: int = $default_period # Period between droplet spawns in lines. (min: 1)
  --batch: int = $default_batch # How many droplets are spawned at once. (min: 1)
  --drop-len: int = $default_drop_len # Length of the whole droplet. (min: 1)
  --tip-len: int = $default_tip_len # Length of droplet's tip. (min: 0)
  --tail-len: int = $default_tail_len # Length of droplet's tail. (min: 0)
  --drop-clr: string = $default_drop_clr # Ansi color code of a droplet.
  --tip-clr: string = $default_tip_clr # Ansi color code of a droplet's tip.
  --tail-clr: string = $default_tail_clr # Ansi color code of a droplet's tail.
  --bg-clr: string = $default_bg_clr # Ansi color code of the background.
  --chars: string = $default_chars # String of symbols used in animation.
]: nothing -> nothing {
  (
    simple-rain-loop
      ([$speed 1] | math max)
      ([$period 1] | math max)
      ([$batch 1] | math max)
      ([$drop_len 1] | math max)
      ([$tip_len 0] | math max)
      ([$tail_len 0] | math max)
      (validate-ansi-color $drop_clr (metadata $drop_clr).span)
      (validate-ansi-color $tip_clr (metadata $tip_clr).span)
      (validate-ansi-color $tail_clr (metadata $tail_clr).span)
      (validate-ansi-color $bg_clr (metadata $bg_clr).span)
      (
        if ($chars | is-not-empty) {
          $chars | split chars
        } else {
          error make {
            msg: "No characters supplied",
            label: {
              text: "This string must not be empty",
              span: (metadata $chars).span
            }
          }
        }
      )
  )
}

# A simple digital rain animation.
export def main [
  --speed: int = $default_speed # Animation speed in lines/sec. (min: 1)
  --period: int = $default_period # Period between droplet spawns in lines. (min: 1)
  --batch: int = $default_batch # How many droplets are spawned at once. (min: 1)
  --drop-len: int = $default_drop_len # Length of the whole droplet. (min: 1)
  --tip-len: int = $default_tip_len # Length of droplet's tip. (min: 0)
  --tail-len: int = $default_tail_len # Length of droplet's tail. (min: 0)
  --drop-clr: string = $default_drop_clr # Ansi color code of a droplet.
  --tip-clr: string = $default_tip_clr # Ansi color code of a droplet's tip.
  --tail-clr: string = $default_tail_clr # Ansi color code of a droplet's tail.
  --bg-clr: string = $default_bg_clr # Ansi color code of the background.
  --chars: string = $default_chars # String of symbols used in animation.
]: nothing -> nothing {
  (
    simple-rain-loop
      ([$speed 1] | math max)
      ([$period 1] | math max)
      ([$batch 1] | math max)
      ([$drop_len 1] | math max)
      ([$tip_len 0] | math max)
      ([$tail_len 0] | math max)
      (validate-ansi-color $drop_clr (metadata $drop_clr).span)
      (validate-ansi-color $tip_clr (metadata $tip_clr).span)
      (validate-ansi-color $tail_clr (metadata $tail_clr).span)
      (validate-ansi-color $bg_clr (metadata $bg_clr).span)
      (
        if ($chars | is-not-empty) {
          $chars | split chars
        } else {
          error make {
            msg: "No characters supplied",
            label: {
              text: "This string must not be empty",
              span: (metadata $chars).span
            }
          }
        }
      )
  )
}