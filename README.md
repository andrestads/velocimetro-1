#  Velocímetro GPS

Um aplicativo Flutter moderno e intuitivo para monitoramento de velocidade em tempo real utilizando GPS.

##  Captura de Tela

<div align="center">
  <img src="assets/images/screenshot.png" alt="Velocímetro GPS Screenshot" width="300"/>
</div>

##  Funcionalidades

-  **Velocímetro em tempo real** - Medição precisa da velocidade atual
-  **Distância percorrida** - Cálculo acumulativo da distância total
-  **Velocidade média** - Análise da velocidade média durante o trajeto
-  **Cronômetro** - Tempo de deslocamento em formato h:m:s
-  **Modo HUD** - Head-Up Display para uso no para-brisa
-  **Reset de dados** - Reinicialização rápida das medições
-  **Interface adaptativa** - Design otimizado para diferentes condições de luz
-  **Tela sempre ativa** - Previne que a tela desligue durante o uso

##  Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento
- **Geolocator** - Serviços de GPS e localização
- **Wakelock Plus** - Controle do estado da tela
- **Intl** - Formatação de números em português brasileiro

##  Pré-requisitos

- Flutter SDK 3.7.0 ou superior
- Android SDK (para build Android)
- Dispositivo com GPS habilitado
- Permissões de localização concedidas

##  Como executar

1. **Clone o repositório:**
```bash
git clone https://github.com/WilliamUcha/velocimetro.git
cd velocimetro
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Execute o aplicativo:**
```bash
flutter run
```

##  Build para produção

### Android (APK):
```bash
flutter build apk --release
```

### Android (Bundle):
```bash
flutter build appbundle --release
```

##  Configurações

O aplicativo requer as seguintes permissões Android:

- `ACCESS_FINE_LOCATION` - Localização precisa via GPS
- `ACCESS_COARSE_LOCATION` - Localização aproximada
- `WAKE_LOCK` - Manter tela ligada durante o uso

##  Como Contribuir

Contribuições são sempre bem-vindas! Para contribuir com o projeto:

1. **Fork o repositório**
2. **Crie uma branch para sua feature:**
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```
3. **Commit suas alterações:**
   ```bash
   git commit -m 'Adiciona nova funcionalidade'
   ```
4. **Push para a branch:**
   ```bash
   git push origin feature/nova-funcionalidade
   ```
5. **Abra um Pull Request**

###  Diretrizes para contribuição:

- Mantenha o código limpo e bem documentado
- Siga as convenções de código do Flutter/Dart
- Teste suas alterações antes de submeter
- Atualize a documentação se necessário
- Descreva claramente as mudanças no PR



##  Autores

<div align="center">

### William Ucha
[![GitHub](https://img.shields.io/badge/GitHub-@WilliamUcha-181717?style=flat&logo=github)](https://github.com/WilliamUcha)

### Bruno Andres
[![GitHub](https://img.shields.io/badge/GitHub-@BrunoAndres-181717?style=flat&logo=github)](https://github.com/andrestads)

</div>

##  Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE.md](LICENSE.md) para mais detalhes.


