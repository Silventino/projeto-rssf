import math


def distanciaEuclidiana(noh1, noh2):
    x = noh1[1]**2 + noh2[1]**2
    y = noh1[2]**2 + noh2[2]**2
    resultado = (x+y)**(1/2)
    return resultado

def calculaAtenuacao(noh1, noh2):
    distancia = distanciaEuclidiana(noh1, noh2)
    return (-45 + (-20 * math.log(distancia, 10)))

with open('grid.txt', 'r') as arquivoLeitura:
    linhas = arquivoLeitura.read().splitlines()
    nohs = []
    for linha in linhas:
        linha = linha.strip().split()
        nohs.append([int(linha[0]), int(linha[1]), int(linha[2])])
        
    
    saida = ""
    for noh in nohs:
        for noh2 in nohs:
            if(noh[0] == noh2[0]):
                continue
            atenuacao = calculaAtenuacao(noh, noh2)
            saida += str(noh[0]) + " " + str(noh2[0]) + " " + str(atenuacao) + "\n"
            
    with open('topo.txt', 'w') as arquivoEscrita:
        arquivoEscrita.write(saida)
    
    #~ print(distanciaEuclidiana(nohs[0], nohs[1]))
    #~ print(calculaAtenuacao(nohs[0], nohs[1]))
    #~ print(calculaAtenuacao(nohs[0], nohs[2]))
    #~ print(calculaAtenuacao(nohs[0], nohs[16]))
    #~ print(calculaAtenuacao(nohs[0], nohs[224]))
