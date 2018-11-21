n = 15
distanciaEntreNos = 20

proximoId = 0
saida = ""
for i in range(n):
    for j in range(n):
        saida += str(proximoId) + " "
        saida += str(j*20) + " "
        saida += str(i*20) + "\n"
        proximoId += 1

with open('grid.txt', 'w') as arquivo:
    arquivo.write(saida)

#~ print(saida)
