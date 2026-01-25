#!/bin/bash

adjectives=(
  swift quiet bold calm dark bright sharp soft wild free quick slow cold warm deep
  silent hidden ancient cosmic crystal frozen golden hollow iron silver
  amber crimson emerald violet azure scarlet ivory obsidian copper bronze
  rapid steady fierce gentle savage tender bitter sweet sour fresh
  dusty misty foggy hazy cloudy stormy sunny lunar solar stellar
  hollow solid liquid molten woven tangled knotted braided twisted curved
  northern southern eastern western polar arctic tropic desert coastal alpine
  primal feral noble regal royal humble modest proud brave clever
)

nouns=(
  falcon river stone forest cloud storm ember frost spark drift peak shore wave flame
  raven wolf tiger panther serpent dragon phoenix griffin sphinx hydra
  oak pine cedar maple willow birch aspen cypress bamboo sequoia
  crystal quartz obsidian jade onyx opal ruby topaz garnet pearl
  canyon valley meadow tundra glacier delta marsh swamp lagoon cavern
  comet meteor nebula pulsar quasar aurora eclipse zenith horizon void
  anvil forge hammer chisel blade arrow shield armor helm gauntlet
  beacon tower bridge gate arch pillar column vault crypt temple
  thunder lightning rain snow hail wind breeze gust cyclone tornado
  dusk dawn twilight midnight noon solstice equinox harvest crescent waning
)

adj=${adjectives[$RANDOM % ${#adjectives[@]}]}
noun=${nouns[$RANDOM % ${#nouns[@]}]}

echo -n "${adj}-${noun}"
