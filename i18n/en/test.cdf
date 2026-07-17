//Base scope block
Dialogs (
    Stage (
        //Variables. Can be numbers, strings, booleans.
        id: 1
        insult: "bitch"
        test_str: "This is %s"
        //Array
        tags: ["intro", "boss_fight", "spring update"]

        //Sequence array
        Sequence (
            Appear (
                id: appear_reimu //Base template other blocks can inherit from via extends
                boss: "reimu"
                final_pos_x: 0
                final_pos_y: 120
            )

            //Reuses Appear's fields via extends, only overriding what's different.
            //final_pos_x/final_pos_y/boss are inherited from the block with id "appear_reimu".
            Appear:AppearMarisa (
                extends: "#appear_reimu" // <- extends target is looked up by id, not by name
                boss: "marisa"
            )

            //Dialog named block. Can be get with `named_dialog_block`
            Dialog:named_dialog_block (
                id: reimu_intro_line
                char: "reimu_1"
                side: "right"
                //Supports lua formatting. And multilines. Skips the tabs/spaces before the text.
                text: """
                EAT PANT MARISA.
                Also this: "%s" is a string that exists.
                """
            )

            Music (
                name: "harai kagura in ruby and pearl" // trailing comment.
            )

            Dialog (
                char: "marisa_5"
                side: "left"
                //Resolves a variable from two levels up. The number of points goes back that many levels. "insult" is two levels up, so two points.
                text: "Reimu you're a {..insult}"
                //Resolves by id instead of relative depth. Can go infinity nesting.
                callback_line: "As {#reimu_intro_line.char} is on side: {#reimu_intro_line.side}"
            )
        )
    )
)

