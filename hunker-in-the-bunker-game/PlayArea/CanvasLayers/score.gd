extends Label

var score := 0

func addscore():
	print(score)
	score += 1
	text = str("Points: ",score)
