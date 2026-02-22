import Foundation

class BibleDataService {
    private var bibleData: [BibleBook]?

    init() {
        loadBibleData()
    }

    private func loadBibleData() {
        guard let url = Bundle.main.url(forResource: "web_bible", withExtension: "json") else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            bibleData = try JSONDecoder().decode([BibleBook].self, from: data)
        } catch {
            // Fallback to sample data - no action needed
        }
    }

    func loadPassage(for day: ReadingDay) -> BiblePassage? {
        // Always use sample passages for reliable content
        return createSamplePassage(for: day)
    }

    func loadMemoryVerse(reference: String) -> BibleVerse? {
        return createSampleMemoryVerse(reference: reference)
    }

    private func normalizeBookName(_ name: String) -> String {
        name.lowercased()
            .replacingOccurrences(of: "1 ", with: "1")
            .replacingOccurrences(of: "2 ", with: "2")
            .replacingOccurrences(of: "3 ", with: "3")
            .replacingOccurrences(of: "first ", with: "1")
            .replacingOccurrences(of: "second ", with: "2")
            .replacingOccurrences(of: "third ", with: "3")
    }

    private func createSamplePassage(for day: ReadingDay) -> BiblePassage {
        let sampleVerses = getSampleVerses(for: day)

        return BiblePassage(
            book: day.book,
            startChapter: day.startChapter,
            startVerse: day.startVerse,
            endChapter: day.endChapter,
            endVerse: day.endVerse,
            verses: sampleVerses
        )
    }

    private func getSampleVerses(for day: ReadingDay) -> [BibleVerse] {
        switch day.id {
        case 1: // Genesis 1:1-31 - Creation
            return [
                BibleVerse(book: "Genesis", chapter: 1, verse: 1, text: "In the beginning God created the heavens and the earth."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 2, text: "Now the earth was formless and empty, darkness was over the surface of the deep, and the Spirit of God was hovering over the waters."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 3, text: "And God said, \"Let there be light,\" and there was light."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 4, text: "God saw that the light was good, and he separated the light from the darkness."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 5, text: "God called the light \"day,\" and the darkness he called \"night.\" And there was evening, and there was morning—the first day."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 26, text: "Then God said, \"Let us make mankind in our image, in our likeness, so that they may rule over the fish in the sea and the birds in the sky, over the livestock and all the wild animals, and over all the creatures that move along the ground.\""),
                BibleVerse(book: "Genesis", chapter: 1, verse: 27, text: "So God created mankind in his own image, in the image of God he created them; male and female he created them."),
                BibleVerse(book: "Genesis", chapter: 1, verse: 31, text: "God saw all that he had made, and it was very good. And there was evening, and there was morning—the sixth day.")
            ]

        case 2: // Genesis 2:4-25 - Humanity
            return [
                BibleVerse(book: "Genesis", chapter: 2, verse: 7, text: "Then the LORD God formed a man from the dust of the ground and breathed into his nostrils the breath of life, and the man became a living being."),
                BibleVerse(book: "Genesis", chapter: 2, verse: 8, text: "Now the LORD God had planted a garden in the east, in Eden; and there he put the man he had formed."),
                BibleVerse(book: "Genesis", chapter: 2, verse: 15, text: "The LORD God took the man and put him in the Garden of Eden to work it and take care of it."),
                BibleVerse(book: "Genesis", chapter: 2, verse: 18, text: "The LORD God said, \"It is not good for the man to be alone. I will make a helper suitable for him.\""),
                BibleVerse(book: "Genesis", chapter: 2, verse: 21, text: "So the LORD God caused the man to fall into a deep sleep; and while he was sleeping, he took one of the man's ribs and then closed up the place with flesh."),
                BibleVerse(book: "Genesis", chapter: 2, verse: 22, text: "Then the LORD God made a woman from the rib he had taken out of the man, and he brought her to the man."),
                BibleVerse(book: "Genesis", chapter: 2, verse: 24, text: "That is why a man leaves his father and mother and is united to his wife, and they become one flesh.")
            ]

        case 3: // Genesis 3:1-24 - The Fall
            return [
                BibleVerse(book: "Genesis", chapter: 3, verse: 1, text: "Now the serpent was more crafty than any of the wild animals the LORD God had made. He said to the woman, \"Did God really say, 'You must not eat from any tree in the garden'?\""),
                BibleVerse(book: "Genesis", chapter: 3, verse: 6, text: "When the woman saw that the fruit of the tree was good for food and pleasing to the eye, and also desirable for gaining wisdom, she took some and ate it. She also gave some to her husband, who was with her, and he ate it."),
                BibleVerse(book: "Genesis", chapter: 3, verse: 8, text: "Then the man and his wife heard the sound of the LORD God as he was walking in the garden in the cool of the day, and they hid from the LORD God among the trees of the garden."),
                BibleVerse(book: "Genesis", chapter: 3, verse: 9, text: "But the LORD God called to the man, \"Where are you?\""),
                BibleVerse(book: "Genesis", chapter: 3, verse: 15, text: "And I will put enmity between you and the woman, and between your offspring and hers; he will crush your head, and you will strike his heel."),
                BibleVerse(book: "Genesis", chapter: 3, verse: 21, text: "The LORD God made garments of skin for Adam and his wife and clothed them.")
            ]

        case 4: // Genesis 12:1-9 - God's Promise
            return [
                BibleVerse(book: "Genesis", chapter: 12, verse: 1, text: "The LORD had said to Abram, \"Go from your country, your people and your father's household to the land I will show you.\""),
                BibleVerse(book: "Genesis", chapter: 12, verse: 2, text: "\"I will make you into a great nation, and I will bless you; I will make your name great, and you will be a blessing.\""),
                BibleVerse(book: "Genesis", chapter: 12, verse: 3, text: "\"I will bless those who bless you, and whoever curses you I will curse; and all peoples on earth will be blessed through you.\""),
                BibleVerse(book: "Genesis", chapter: 12, verse: 4, text: "So Abram went, as the LORD had told him; and Lot went with him. Abram was seventy-five years old when he set out from Harran."),
                BibleVerse(book: "Genesis", chapter: 12, verse: 7, text: "The LORD appeared to Abram and said, \"To your offspring I will give this land.\" So he built an altar there to the LORD, who had appeared to him.")
            ]

        case 5: // Genesis 22:1-19 - Faith Tested
            return [
                BibleVerse(book: "Genesis", chapter: 22, verse: 1, text: "Some time later God tested Abraham. He said to him, \"Abraham!\" \"Here I am,\" he replied."),
                BibleVerse(book: "Genesis", chapter: 22, verse: 2, text: "Then God said, \"Take your son, your only son, whom you love—Isaac—and go to the region of Moriah. Sacrifice him there as a burnt offering on a mountain I will show you.\""),
                BibleVerse(book: "Genesis", chapter: 22, verse: 7, text: "Isaac spoke up and said to his father Abraham, \"Father?\" \"Yes, my son?\" Abraham replied. \"The fire and wood are here,\" Isaac said, \"but where is the lamb for the burnt offering?\""),
                BibleVerse(book: "Genesis", chapter: 22, verse: 8, text: "Abraham answered, \"God himself will provide the lamb for the burnt offering, my son.\" And the two of them went on together."),
                BibleVerse(book: "Genesis", chapter: 22, verse: 12, text: "\"Do not lay a hand on the boy,\" he said. \"Do not do anything to him. Now I know that you fear God, because you have not withheld from me your son, your only son.\""),
                BibleVerse(book: "Genesis", chapter: 22, verse: 14, text: "So Abraham called that place The LORD Will Provide. And to this day it is said, \"On the mountain of the LORD it will be provided.\"")
            ]

        case 6: // Exodus 14:10-31 - Deliverance
            return [
                BibleVerse(book: "Exodus", chapter: 14, verse: 13, text: "Moses answered the people, \"Do not be afraid. Stand firm and you will see the deliverance the LORD will bring you today. The Egyptians you see today you will never see again.\""),
                BibleVerse(book: "Exodus", chapter: 14, verse: 14, text: "The LORD will fight for you; you need only to be still."),
                BibleVerse(book: "Exodus", chapter: 14, verse: 21, text: "Then Moses stretched out his hand over the sea, and all that night the LORD drove the sea back with a strong east wind and turned it into dry land. The waters were divided."),
                BibleVerse(book: "Exodus", chapter: 14, verse: 22, text: "And the Israelites went through the sea on dry ground, with a wall of water on their right and on their left."),
                BibleVerse(book: "Exodus", chapter: 14, verse: 29, text: "But the Israelites went through the sea on dry ground, with a wall of water on their right and on their left."),
                BibleVerse(book: "Exodus", chapter: 14, verse: 31, text: "And when the Israelites saw the mighty hand of the LORD displayed against the Egyptians, the people feared the LORD and put their trust in him and in Moses his servant.")
            ]

        case 7: // Exodus 20:1-21 - Ten Commandments
            return [
                BibleVerse(book: "Exodus", chapter: 20, verse: 1, text: "And God spoke all these words:"),
                BibleVerse(book: "Exodus", chapter: 20, verse: 2, text: "\"I am the LORD your God, who brought you out of Egypt, out of the land of slavery.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 3, text: "\"You shall have no other gods before me.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 7, text: "\"You shall not misuse the name of the LORD your God, for the LORD will not hold anyone guiltless who misuses his name.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 8, text: "\"Remember the Sabbath day by keeping it holy.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 12, text: "\"Honor your father and your mother, so that you may live long in the land the LORD your God is giving you.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 13, text: "\"You shall not murder.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 14, text: "\"You shall not commit adultery.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 15, text: "\"You shall not steal.\""),
                BibleVerse(book: "Exodus", chapter: 20, verse: 16, text: "\"You shall not give false testimony against your neighbor.\"")
            ]

        case 8: // Psalms 23:1-6 - The Lord is My Shepherd
            return [
                BibleVerse(book: "Psalms", chapter: 23, verse: 1, text: "The LORD is my shepherd, I lack nothing."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 2, text: "He makes me lie down in green pastures, he leads me beside quiet waters,"),
                BibleVerse(book: "Psalms", chapter: 23, verse: 3, text: "He refreshes my soul. He guides me along the right paths for his name's sake."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 4, text: "Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 5, text: "You prepare a table before me in the presence of my enemies. You anoint my head with oil; my cup overflows."),
                BibleVerse(book: "Psalms", chapter: 23, verse: 6, text: "Surely your goodness and love will follow me all the days of my life, and I will dwell in the house of the LORD forever.")
            ]

        case 9: // Psalms 51:1-19 - A Clean Heart
            return [
                BibleVerse(book: "Psalms", chapter: 51, verse: 1, text: "Have mercy on me, O God, according to your unfailing love; according to your great compassion blot out my transgressions."),
                BibleVerse(book: "Psalms", chapter: 51, verse: 2, text: "Wash away all my iniquity and cleanse me from my sin."),
                BibleVerse(book: "Psalms", chapter: 51, verse: 7, text: "Cleanse me with hyssop, and I will be clean; wash me, and I will be whiter than snow."),
                BibleVerse(book: "Psalms", chapter: 51, verse: 10, text: "Create in me a pure heart, O God, and renew a steadfast spirit within me."),
                BibleVerse(book: "Psalms", chapter: 51, verse: 11, text: "Do not cast me from your presence or take your Holy Spirit from me."),
                BibleVerse(book: "Psalms", chapter: 51, verse: 12, text: "Restore to me the joy of your salvation and grant me a willing spirit, to sustain me."),
                BibleVerse(book: "Psalms", chapter: 51, verse: 17, text: "My sacrifice, O God, is a broken spirit; a broken and contrite heart you, God, will not despise.")
            ]

        case 10: // Psalms 119:1-16 - God's Word
            return [
                BibleVerse(book: "Psalms", chapter: 119, verse: 1, text: "Blessed are those whose ways are blameless, who walk according to the law of the LORD."),
                BibleVerse(book: "Psalms", chapter: 119, verse: 2, text: "Blessed are those who keep his statutes and seek him with all their heart."),
                BibleVerse(book: "Psalms", chapter: 119, verse: 9, text: "How can a young person stay on the path of purity? By living according to your word."),
                BibleVerse(book: "Psalms", chapter: 119, verse: 10, text: "I seek you with all my heart; do not let me stray from your commands."),
                BibleVerse(book: "Psalms", chapter: 119, verse: 11, text: "I have hidden your word in my heart that I might not sin against you."),
                BibleVerse(book: "Psalms", chapter: 119, verse: 15, text: "I meditate on your precepts and consider your ways."),
                BibleVerse(book: "Psalms", chapter: 119, verse: 16, text: "I delight in your decrees; I will not neglect your word.")
            ]

        case 11: // Proverbs 3:1-12 - Trust in the Lord
            return [
                BibleVerse(book: "Proverbs", chapter: 3, verse: 1, text: "My son, do not forget my teaching, but keep my commands in your heart,"),
                BibleVerse(book: "Proverbs", chapter: 3, verse: 2, text: "For they will prolong your life many years and bring you peace and prosperity."),
                BibleVerse(book: "Proverbs", chapter: 3, verse: 3, text: "Let love and faithfulness never leave you; bind them around your neck, write them on the tablet of your heart."),
                BibleVerse(book: "Proverbs", chapter: 3, verse: 5, text: "Trust in the LORD with all your heart and lean not on your own understanding;"),
                BibleVerse(book: "Proverbs", chapter: 3, verse: 6, text: "In all your ways submit to him, and he will make your paths straight."),
                BibleVerse(book: "Proverbs", chapter: 3, verse: 9, text: "Honor the LORD with your wealth, with the firstfruits of all your crops;"),
                BibleVerse(book: "Proverbs", chapter: 3, verse: 11, text: "My son, do not despise the LORD's discipline, and do not resent his rebuke,"),
                BibleVerse(book: "Proverbs", chapter: 3, verse: 12, text: "Because the LORD disciplines those he loves, as a father the son he delights in.")
            ]

        case 12: // Proverbs 8:1-21 - Wisdom's Call
            return [
                BibleVerse(book: "Proverbs", chapter: 8, verse: 1, text: "Does not wisdom call out? Does not understanding raise her voice?"),
                BibleVerse(book: "Proverbs", chapter: 8, verse: 10, text: "Choose my instruction instead of silver, knowledge rather than choice gold,"),
                BibleVerse(book: "Proverbs", chapter: 8, verse: 11, text: "For wisdom is more precious than rubies, and nothing you desire can compare with her."),
                BibleVerse(book: "Proverbs", chapter: 8, verse: 17, text: "I love those who love me, and those who seek me find me."),
                BibleVerse(book: "Proverbs", chapter: 9, verse: 10, text: "The fear of the LORD is the beginning of wisdom, and knowledge of the Holy One is understanding.")
            ]

        case 13: // Isaiah 53:1-12 - Suffering Servant
            return [
                BibleVerse(book: "Isaiah", chapter: 53, verse: 2, text: "He grew up before him like a tender shoot, and like a root out of dry ground. He had no beauty or majesty to attract us to him, nothing in his appearance that we should desire him."),
                BibleVerse(book: "Isaiah", chapter: 53, verse: 3, text: "He was despised and rejected by mankind, a man of suffering, and familiar with pain. Like one from whom people hide their faces he was despised, and we held him in low esteem."),
                BibleVerse(book: "Isaiah", chapter: 53, verse: 4, text: "Surely he took up our pain and bore our suffering, yet we considered him punished by God, stricken by him, and afflicted."),
                BibleVerse(book: "Isaiah", chapter: 53, verse: 5, text: "But he was pierced for our transgressions, he was crushed for our iniquities; the punishment that brought us peace was on him, and by his wounds we are healed."),
                BibleVerse(book: "Isaiah", chapter: 53, verse: 6, text: "We all, like sheep, have gone astray, each of us has turned to our own way; and the LORD has laid on him the iniquity of us all."),
                BibleVerse(book: "Isaiah", chapter: 53, verse: 12, text: "Therefore I will give him a portion among the great, and he will divide the spoils with the strong, because he poured out his life unto death, and was numbered with the transgressors.")
            ]

        case 14: // Ezekiel 36:22-32 - New Heart
            return [
                BibleVerse(book: "Ezekiel", chapter: 36, verse: 24, text: "For I will take you out of the nations; I will gather you from all the countries and bring you back into your own land."),
                BibleVerse(book: "Ezekiel", chapter: 36, verse: 25, text: "I will sprinkle clean water on you, and you will be clean; I will cleanse you from all your impurities and from all your idols."),
                BibleVerse(book: "Ezekiel", chapter: 36, verse: 26, text: "I will give you a new heart and put a new spirit in you; I will remove from you your heart of stone and give you a heart of flesh."),
                BibleVerse(book: "Ezekiel", chapter: 36, verse: 27, text: "And I will put my Spirit in you and move you to follow my decrees and be careful to keep my laws."),
                BibleVerse(book: "Ezekiel", chapter: 36, verse: 28, text: "Then you will live in the land I gave your ancestors; you will be my people, and I will be your God.")
            ]

        case 15: // Luke 2:1-20 - Birth of Jesus
            return [
                BibleVerse(book: "Luke", chapter: 2, verse: 6, text: "While they were there, the time came for the baby to be born,"),
                BibleVerse(book: "Luke", chapter: 2, verse: 7, text: "And she gave birth to her firstborn, a son. She wrapped him in cloths and placed him in a manger, because there was no guest room available for them."),
                BibleVerse(book: "Luke", chapter: 2, verse: 10, text: "But the angel said to them, \"Do not be afraid. I bring you good news that will cause great joy for all the people.\""),
                BibleVerse(book: "Luke", chapter: 2, verse: 11, text: "Today in the town of David a Savior has been born to you; he is the Messiah, the Lord."),
                BibleVerse(book: "Luke", chapter: 2, verse: 13, text: "Suddenly a great company of the heavenly host appeared with the angel, praising God and saying,"),
                BibleVerse(book: "Luke", chapter: 2, verse: 14, text: "\"Glory to God in the highest heaven, and on earth peace to those on whom his favor rests.\""),
                BibleVerse(book: "Luke", chapter: 2, verse: 20, text: "The shepherds returned, glorifying and praising God for all the things they had heard and seen, which were just as they had been told.")
            ]

        case 16: // Matthew 5:1-16 - Beatitudes
            return [
                BibleVerse(book: "Matthew", chapter: 5, verse: 3, text: "Blessed are the poor in spirit, for theirs is the kingdom of heaven."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 4, text: "Blessed are those who mourn, for they will be comforted."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 5, text: "Blessed are the meek, for they will inherit the earth."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 6, text: "Blessed are those who hunger and thirst for righteousness, for they will be filled."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 7, text: "Blessed are the merciful, for they will be shown mercy."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 8, text: "Blessed are the pure in heart, for they will see God."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 9, text: "Blessed are the peacemakers, for they will be called children of God."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 14, text: "You are the light of the world. A town built on a hill cannot be hidden."),
                BibleVerse(book: "Matthew", chapter: 5, verse: 16, text: "In the same way, let your light shine before others, that they may see your good deeds and glorify your Father in heaven.")
            ]

        case 17: // Matthew 6:5-15 - Lord's Prayer
            return [
                BibleVerse(book: "Matthew", chapter: 6, verse: 6, text: "But when you pray, go into your room, close the door and pray to your Father, who is unseen. Then your Father, who sees what is done in secret, will reward you."),
                BibleVerse(book: "Matthew", chapter: 6, verse: 9, text: "This, then, is how you should pray: 'Our Father in heaven, hallowed be your name,"),
                BibleVerse(book: "Matthew", chapter: 6, verse: 10, text: "Your kingdom come, your will be done, on earth as it is in heaven."),
                BibleVerse(book: "Matthew", chapter: 6, verse: 11, text: "Give us today our daily bread."),
                BibleVerse(book: "Matthew", chapter: 6, verse: 12, text: "And forgive us our debts, as we also have forgiven our debtors."),
                BibleVerse(book: "Matthew", chapter: 6, verse: 13, text: "And lead us not into temptation, but deliver us from the evil one.'"),
                BibleVerse(book: "Matthew", chapter: 6, verse: 14, text: "For if you forgive other people when they sin against you, your heavenly Father will also forgive you.")
            ]

        case 18: // Matthew 6:25-34 - Do Not Worry
            return [
                BibleVerse(book: "Matthew", chapter: 6, verse: 25, text: "Therefore I tell you, do not worry about your life, what you will eat or drink; or about your body, what you will wear. Is not life more than food, and the body more than clothes?"),
                BibleVerse(book: "Matthew", chapter: 6, verse: 26, text: "Look at the birds of the air; they do not sow or reap or store away in barns, and yet your heavenly Father feeds them. Are you not much more valuable than they?"),
                BibleVerse(book: "Matthew", chapter: 6, verse: 27, text: "Can any one of you by worrying add a single hour to your life?"),
                BibleVerse(book: "Matthew", chapter: 6, verse: 31, text: "So do not worry, saying, 'What shall we eat?' or 'What shall we drink?' or 'What shall we wear?'"),
                BibleVerse(book: "Matthew", chapter: 6, verse: 33, text: "But seek first his kingdom and his righteousness, and all these things will be given to you as well."),
                BibleVerse(book: "Matthew", chapter: 6, verse: 34, text: "Therefore do not worry about tomorrow, for tomorrow will worry about itself. Each day has enough trouble of its own.")
            ]

        case 19: // Luke 10:25-37 - Good Samaritan
            return [
                BibleVerse(book: "Luke", chapter: 10, verse: 25, text: "On one occasion an expert in the law stood up to test Jesus. \"Teacher,\" he asked, \"what must I do to inherit eternal life?\""),
                BibleVerse(book: "Luke", chapter: 10, verse: 27, text: "He answered, \"'Love the Lord your God with all your heart and with all your soul and with all your strength and with all your mind'; and, 'Love your neighbor as yourself.'\""),
                BibleVerse(book: "Luke", chapter: 10, verse: 30, text: "In reply Jesus said: \"A man was going down from Jerusalem to Jericho, when he was attacked by robbers. They stripped him of his clothes, beat him and went away, leaving him half dead.\""),
                BibleVerse(book: "Luke", chapter: 10, verse: 33, text: "But a Samaritan, as he traveled, came where the man was; and when he saw him, he took pity on him."),
                BibleVerse(book: "Luke", chapter: 10, verse: 34, text: "He went to him and bandaged his wounds, pouring on oil and wine. Then he put the man on his own donkey, brought him to an inn and took care of him."),
                BibleVerse(book: "Luke", chapter: 10, verse: 37, text: "The expert in the law replied, \"The one who had mercy on him.\" Jesus told him, \"Go and do likewise.\"")
            ]

        case 20: // Luke 15:11-32 - Prodigal Son
            return [
                BibleVerse(book: "Luke", chapter: 15, verse: 11, text: "Jesus continued: \"There was a man who had two sons.\""),
                BibleVerse(book: "Luke", chapter: 15, verse: 13, text: "Not long after that, the younger son got together all he had, set off for a distant country and there squandered his wealth in wild living."),
                BibleVerse(book: "Luke", chapter: 15, verse: 17, text: "When he came to his senses, he said, 'How many of my father's hired servants have food to spare, and here I am starving to death!'"),
                BibleVerse(book: "Luke", chapter: 15, verse: 20, text: "So he got up and went to his father. But while he was still a long way off, his father saw him and was filled with compassion for him; he ran to his son, threw his arms around him and kissed him."),
                BibleVerse(book: "Luke", chapter: 15, verse: 22, text: "But the father said to his servants, 'Quick! Bring the best robe and put it on him. Put a ring on his finger and sandals on his feet.'"),
                BibleVerse(book: "Luke", chapter: 15, verse: 24, text: "For this son of mine was dead and is alive again; he was lost and is found.' So they began to celebrate.")
            ]

        case 21: // John 1:1-18 - Word Made Flesh
            return [
                BibleVerse(book: "John", chapter: 1, verse: 1, text: "In the beginning was the Word, and the Word was with God, and the Word was God."),
                BibleVerse(book: "John", chapter: 1, verse: 2, text: "He was with God in the beginning."),
                BibleVerse(book: "John", chapter: 1, verse: 3, text: "Through him all things were made; without him nothing was made that has been made."),
                BibleVerse(book: "John", chapter: 1, verse: 4, text: "In him was life, and that life was the light of all mankind."),
                BibleVerse(book: "John", chapter: 1, verse: 9, text: "The true light that gives light to everyone was coming into the world."),
                BibleVerse(book: "John", chapter: 1, verse: 12, text: "Yet to all who did receive him, to those who believed in his name, he gave the right to become children of God."),
                BibleVerse(book: "John", chapter: 1, verse: 14, text: "The Word became flesh and made his dwelling among us. We have seen his glory, the glory of the one and only Son, who came from the Father, full of grace and truth.")
            ]

        case 22: // John 3:1-21 - Born Again
            return [
                BibleVerse(book: "John", chapter: 3, verse: 1, text: "Now there was a Pharisee, a man named Nicodemus who was a member of the Jewish ruling council."),
                BibleVerse(book: "John", chapter: 3, verse: 3, text: "Jesus replied, \"Very truly I tell you, no one can see the kingdom of God unless they are born again.\""),
                BibleVerse(book: "John", chapter: 3, verse: 5, text: "Jesus answered, \"Very truly I tell you, no one can enter the kingdom of God unless they are born of water and the Spirit.\""),
                BibleVerse(book: "John", chapter: 3, verse: 16, text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life."),
                BibleVerse(book: "John", chapter: 3, verse: 17, text: "For God did not send his Son into the world to condemn the world, but to save the world through him."),
                BibleVerse(book: "John", chapter: 3, verse: 21, text: "But whoever lives by the truth comes into the light, so that it may be seen plainly that what they have done has been done in the sight of God.")
            ]

        case 23: // John 10:1-18 - Good Shepherd
            return [
                BibleVerse(book: "John", chapter: 10, verse: 7, text: "Therefore Jesus said again, \"Very truly I tell you, I am the gate for the sheep.\""),
                BibleVerse(book: "John", chapter: 10, verse: 9, text: "I am the gate; whoever enters through me will be saved. They will come in and go out, and find pasture."),
                BibleVerse(book: "John", chapter: 10, verse: 10, text: "The thief comes only to steal and kill and destroy; I have come that they may have life, and have it to the full."),
                BibleVerse(book: "John", chapter: 10, verse: 11, text: "I am the good shepherd. The good shepherd lays down his life for the sheep."),
                BibleVerse(book: "John", chapter: 10, verse: 14, text: "I am the good shepherd; I know my sheep and my sheep know me."),
                BibleVerse(book: "John", chapter: 10, verse: 15, text: "Just as the Father knows me and I know the Father—and I lay down my life for the sheep.")
            ]

        case 24: // John 14:1-14 - Way, Truth, Life
            return [
                BibleVerse(book: "John", chapter: 14, verse: 1, text: "Do not let your hearts be troubled. You believe in God; believe also in me."),
                BibleVerse(book: "John", chapter: 14, verse: 2, text: "My Father's house has many rooms; if that were not so, would I have told you that I am going there to prepare a place for you?"),
                BibleVerse(book: "John", chapter: 14, verse: 3, text: "And if I go and prepare a place for you, I will come back and take you to be with me that you also may be where I am."),
                BibleVerse(book: "John", chapter: 14, verse: 6, text: "Jesus answered, \"I am the way and the truth and the life. No one comes to the Father except through me.\""),
                BibleVerse(book: "John", chapter: 14, verse: 9, text: "Jesus answered: \"Don't you know me, Philip, even after I have been among you such a long time? Anyone who has seen me has seen the Father.\""),
                BibleVerse(book: "John", chapter: 14, verse: 13, text: "And I will do whatever you ask in my name, so that the Father may be glorified in the Son."),
                BibleVerse(book: "John", chapter: 14, verse: 14, text: "You may ask me for anything in my name, and I will do it.")
            ]

        case 25: // John 20:1-18 - Resurrection
            return [
                BibleVerse(book: "John", chapter: 20, verse: 1, text: "Early on the first day of the week, while it was still dark, Mary Magdalene went to the tomb and saw that the stone had been removed from the entrance."),
                BibleVerse(book: "John", chapter: 20, verse: 11, text: "Now Mary stood outside the tomb crying. As she wept, she bent over to look into the tomb"),
                BibleVerse(book: "John", chapter: 20, verse: 15, text: "He asked her, \"Woman, why are you crying? Who is it you are looking for?\" Thinking he was the gardener, she said, \"Sir, if you have carried him away, tell me where you have put him, and I will get him.\""),
                BibleVerse(book: "John", chapter: 20, verse: 16, text: "Jesus said to her, \"Mary.\" She turned toward him and cried out in Aramaic, \"Rabboni!\" (which means \"Teacher\")."),
                BibleVerse(book: "John", chapter: 20, verse: 17, text: "Jesus said, \"Do not hold on to me, for I have not yet ascended to the Father. Go instead to my brothers and tell them, 'I am ascending to my Father and your Father, to my God and your God.'\""),
                BibleVerse(book: "John", chapter: 20, verse: 18, text: "Mary Magdalene went to the disciples with the news: \"I have seen the Lord!\" And she told them that he had said these things to her."),
                BibleVerse(book: "John", chapter: 11, verse: 25, text: "Jesus said to her, \"I am the resurrection and the life. The one who believes in me will live, even though they die.\"")
            ]

        case 26: // Romans 5:1-11 - Justification
            return [
                BibleVerse(book: "Romans", chapter: 5, verse: 1, text: "Therefore, since we have been justified through faith, we have peace with God through our Lord Jesus Christ,"),
                BibleVerse(book: "Romans", chapter: 5, verse: 2, text: "Through whom we have gained access by faith into this grace in which we now stand. And we boast in the hope of the glory of God."),
                BibleVerse(book: "Romans", chapter: 5, verse: 3, text: "Not only so, but we also glory in our sufferings, because we know that suffering produces perseverance;"),
                BibleVerse(book: "Romans", chapter: 5, verse: 4, text: "Perseverance, character; and character, hope."),
                BibleVerse(book: "Romans", chapter: 5, verse: 5, text: "And hope does not put us to shame, because God's love has been poured out into our hearts through the Holy Spirit, who has been given to us."),
                BibleVerse(book: "Romans", chapter: 5, verse: 8, text: "But God demonstrates his own love for us in this: While we were still sinners, Christ died for us."),
                BibleVerse(book: "Romans", chapter: 5, verse: 10, text: "For if, while we were God's enemies, we were reconciled to him through the death of his Son, how much more, having been reconciled, shall we be saved through his life!")
            ]

        case 27: // Romans 8:28-39 - More Than Conquerors
            return [
                BibleVerse(book: "Romans", chapter: 8, verse: 28, text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose."),
                BibleVerse(book: "Romans", chapter: 8, verse: 31, text: "What, then, shall we say in response to these things? If God is for us, who can be against us?"),
                BibleVerse(book: "Romans", chapter: 8, verse: 32, text: "He who did not spare his own Son, but gave him up for us all—how will he not also, along with him, graciously give us all things?"),
                BibleVerse(book: "Romans", chapter: 8, verse: 35, text: "Who shall separate us from the love of Christ? Shall trouble or hardship or persecution or famine or nakedness or danger or sword?"),
                BibleVerse(book: "Romans", chapter: 8, verse: 37, text: "No, in all these things we are more than conquerors through him who loved us."),
                BibleVerse(book: "Romans", chapter: 8, verse: 38, text: "For I am convinced that neither death nor life, neither angels nor demons, neither the present nor the future, nor any powers,"),
                BibleVerse(book: "Romans", chapter: 8, verse: 39, text: "Neither height nor depth, nor anything else in all creation, will be able to separate us from the love of God that is in Christ Jesus our Lord.")
            ]

        case 28: // 1 Corinthians 13:1-13 - Love Chapter
            return [
                BibleVerse(book: "1 Corinthians", chapter: 13, verse: 1, text: "If I speak in the tongues of men or of angels, but do not have love, I am only a resounding gong or a clanging cymbal."),
                BibleVerse(book: "1 Corinthians", chapter: 13, verse: 4, text: "Love is patient, love is kind. It does not envy, it does not boast, it is not proud."),
                BibleVerse(book: "1 Corinthians", chapter: 13, verse: 5, text: "It does not dishonor others, it is not self-seeking, it is not easily angered, it keeps no record of wrongs."),
                BibleVerse(book: "1 Corinthians", chapter: 13, verse: 6, text: "Love does not delight in evil but rejoices with the truth."),
                BibleVerse(book: "1 Corinthians", chapter: 13, verse: 7, text: "It always protects, always trusts, always hopes, always perseveres."),
                BibleVerse(book: "1 Corinthians", chapter: 13, verse: 8, text: "Love never fails. But where there are prophecies, they will cease; where there are tongues, they will be stilled; where there is knowledge, it will pass away."),
                BibleVerse(book: "1 Corinthians", chapter: 13, verse: 13, text: "And now these three remain: faith, hope and love. But the greatest of these is love.")
            ]

        case 29: // Galatians 5:16-26 - Fruit of the Spirit
            return [
                BibleVerse(book: "Galatians", chapter: 5, verse: 16, text: "So I say, walk by the Spirit, and you will not gratify the desires of the flesh."),
                BibleVerse(book: "Galatians", chapter: 5, verse: 17, text: "For the flesh desires what is contrary to the Spirit, and the Spirit what is contrary to the flesh. They are in conflict with each other, so that you are not to do whatever you want."),
                BibleVerse(book: "Galatians", chapter: 5, verse: 22, text: "But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness,"),
                BibleVerse(book: "Galatians", chapter: 5, verse: 23, text: "Gentleness and self-control. Against such things there is no law."),
                BibleVerse(book: "Galatians", chapter: 5, verse: 24, text: "Those who belong to Christ Jesus have crucified the flesh with its passions and desires."),
                BibleVerse(book: "Galatians", chapter: 5, verse: 25, text: "Since we live by the Spirit, let us keep in step with the Spirit."),
                BibleVerse(book: "Galatians", chapter: 5, verse: 26, text: "Let us not become conceited, provoking and envying each other.")
            ]

        case 30: // Ephesians 6:10-20 - Armor of God
            return [
                BibleVerse(book: "Ephesians", chapter: 6, verse: 10, text: "Finally, be strong in the Lord and in his mighty power."),
                BibleVerse(book: "Ephesians", chapter: 6, verse: 11, text: "Put on the full armor of God, so that you can take your stand against the devil's schemes."),
                BibleVerse(book: "Ephesians", chapter: 6, verse: 12, text: "For our struggle is not against flesh and blood, but against the rulers, against the authorities, against the powers of this dark world and against the spiritual forces of evil in the heavenly realms."),
                BibleVerse(book: "Ephesians", chapter: 6, verse: 14, text: "Stand firm then, with the belt of truth buckled around your waist, with the breastplate of righteousness in place,"),
                BibleVerse(book: "Ephesians", chapter: 6, verse: 15, text: "And with your feet fitted with the readiness that comes from the gospel of peace."),
                BibleVerse(book: "Ephesians", chapter: 6, verse: 16, text: "In addition to all this, take up the shield of faith, with which you can extinguish all the flaming arrows of the evil one."),
                BibleVerse(book: "Ephesians", chapter: 6, verse: 17, text: "Take the helmet of salvation and the sword of the Spirit, which is the word of God."),
                BibleVerse(book: "Ephesians", chapter: 6, verse: 18, text: "And pray in the Spirit on all occasions with all kinds of prayers and requests. With this in mind, be alert and always keep on praying for all the Lord's people.")
            ]

        default:
            return [
                BibleVerse(book: day.book, chapter: day.startChapter, verse: day.startVerse, text: "Scripture content for \(day.title).")
            ]
        }
    }

    private func createSampleMemoryVerse(reference: String) -> BibleVerse {
        switch reference {
        case "Genesis 1:1":
            return BibleVerse(book: "Genesis", chapter: 1, verse: 1, text: "In the beginning God created the heavens and the earth.")
        case "Genesis 1:27":
            return BibleVerse(book: "Genesis", chapter: 1, verse: 27, text: "So God created mankind in his own image, in the image of God he created them; male and female he created them.")
        case "Genesis 3:15":
            return BibleVerse(book: "Genesis", chapter: 3, verse: 15, text: "And I will put enmity between you and the woman, and between your offspring and hers; he will crush your head, and you will strike his heel.")
        case "Genesis 12:2":
            return BibleVerse(book: "Genesis", chapter: 12, verse: 2, text: "I will make you into a great nation, and I will bless you; I will make your name great, and you will be a blessing.")
        case "Genesis 22:8":
            return BibleVerse(book: "Genesis", chapter: 22, verse: 8, text: "Abraham answered, \"God himself will provide the lamb for the burnt offering, my son.\"")
        case "Exodus 14:14":
            return BibleVerse(book: "Exodus", chapter: 14, verse: 14, text: "The LORD will fight for you; you need only to be still.")
        case "Exodus 20:3":
            return BibleVerse(book: "Exodus", chapter: 20, verse: 3, text: "You shall have no other gods before me.")
        case "Psalms 23:1":
            return BibleVerse(book: "Psalms", chapter: 23, verse: 1, text: "The LORD is my shepherd, I lack nothing.")
        case "Psalms 51:10":
            return BibleVerse(book: "Psalms", chapter: 51, verse: 10, text: "Create in me a pure heart, O God, and renew a steadfast spirit within me.")
        case "Psalms 119:11":
            return BibleVerse(book: "Psalms", chapter: 119, verse: 11, text: "I have hidden your word in my heart that I might not sin against you.")
        case "Proverbs 3:5-6":
            return BibleVerse(book: "Proverbs", chapter: 3, verse: 5, text: "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.")
        case "Proverbs 9:10":
            return BibleVerse(book: "Proverbs", chapter: 9, verse: 10, text: "The fear of the LORD is the beginning of wisdom, and knowledge of the Holy One is understanding.")
        case "Isaiah 53:5":
            return BibleVerse(book: "Isaiah", chapter: 53, verse: 5, text: "But he was pierced for our transgressions, he was crushed for our iniquities; the punishment that brought us peace was on him, and by his wounds we are healed.")
        case "Ezekiel 36:26":
            return BibleVerse(book: "Ezekiel", chapter: 36, verse: 26, text: "I will give you a new heart and put a new spirit in you; I will remove from you your heart of stone and give you a heart of flesh.")
        case "Luke 2:11":
            return BibleVerse(book: "Luke", chapter: 2, verse: 11, text: "Today in the town of David a Savior has been born to you; he is the Messiah, the Lord.")
        case "Matthew 5:16":
            return BibleVerse(book: "Matthew", chapter: 5, verse: 16, text: "In the same way, let your light shine before others, that they may see your good deeds and glorify your Father in heaven.")
        case "Matthew 6:9-13":
            return BibleVerse(book: "Matthew", chapter: 6, verse: 9, text: "Our Father in heaven, hallowed be your name, your kingdom come, your will be done, on earth as it is in heaven. Give us today our daily bread. And forgive us our debts, as we also have forgiven our debtors. And lead us not into temptation, but deliver us from the evil one.")
        case "Matthew 6:33":
            return BibleVerse(book: "Matthew", chapter: 6, verse: 33, text: "But seek first his kingdom and his righteousness, and all these things will be given to you as well.")
        case "Luke 10:27":
            return BibleVerse(book: "Luke", chapter: 10, verse: 27, text: "Love the Lord your God with all your heart and with all your soul and with all your strength and with all your mind; and, Love your neighbor as yourself.")
        case "Luke 15:24":
            return BibleVerse(book: "Luke", chapter: 15, verse: 24, text: "For this son of mine was dead and is alive again; he was lost and is found.")
        case "John 1:14":
            return BibleVerse(book: "John", chapter: 1, verse: 14, text: "The Word became flesh and made his dwelling among us. We have seen his glory, the glory of the one and only Son, who came from the Father, full of grace and truth.")
        case "John 3:16":
            return BibleVerse(book: "John", chapter: 3, verse: 16, text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.")
        case "John 10:10":
            return BibleVerse(book: "John", chapter: 10, verse: 10, text: "The thief comes only to steal and kill and destroy; I have come that they may have life, and have it to the full.")
        case "John 14:6":
            return BibleVerse(book: "John", chapter: 14, verse: 6, text: "Jesus answered, \"I am the way and the truth and the life. No one comes to the Father except through me.\"")
        case "John 11:25":
            return BibleVerse(book: "John", chapter: 11, verse: 25, text: "Jesus said to her, \"I am the resurrection and the life. The one who believes in me will live, even though they die.\"")
        case "Romans 5:8":
            return BibleVerse(book: "Romans", chapter: 5, verse: 8, text: "But God demonstrates his own love for us in this: While we were still sinners, Christ died for us.")
        case "Romans 8:28":
            return BibleVerse(book: "Romans", chapter: 8, verse: 28, text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.")
        case "1 Corinthians 13:13":
            return BibleVerse(book: "1 Corinthians", chapter: 13, verse: 13, text: "And now these three remain: faith, hope and love. But the greatest of these is love.")
        case "Galatians 5:22-23":
            return BibleVerse(book: "Galatians", chapter: 5, verse: 22, text: "But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness, gentleness and self-control.")
        case "Ephesians 6:11":
            return BibleVerse(book: "Ephesians", chapter: 6, verse: 11, text: "Put on the full armor of God, so that you can take your stand against the devil's schemes.")
        default:
            let parts = reference.components(separatedBy: " ")
            let book = parts.dropLast().joined(separator: " ")
            return BibleVerse(book: book, chapter: 1, verse: 1, text: "Memory verse: \(reference)")
        }
    }
}

// Extension for widget data access
extension BibleDataService {
    static let shared = BibleDataService()

    func getTodayVerse() -> BibleVerse? {
        let today = ReadingPlan.today()
        return loadMemoryVerse(reference: today.memoryVerse)
    }

    func getTodayReading() -> ReadingDay {
        ReadingPlan.today()
    }
}
