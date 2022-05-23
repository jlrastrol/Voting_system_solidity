//SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

// -----------------------------------
//  CANDIDATO   |   EDAD   |      ID (DNI)
// -----------------------------------
//  Toni        |    20    |    12345X
//  Alberto     |    23    |    54321T
//  Joan        |    21    |    98765P
//  Javier      |    19    |    56789W

contract votacion {

    // Dirección del propietario del contrato
    address owner;

    // Constructor
    constructor() public{
        owner = msg.sender;
    }

    // Relación entre el nombre del candidato y el hash de sus datos personales
    mapping(string => bytes32) ID_candidato;
    
    // Relación entre el nombre del candidato y el número de votos
    mapping(string => uint) votos_candidato;

    // Lista para almacenar los nombres de los candidatos
    string [] candidatos;

    // Lista de hashes de la identidad de los votantes
    bytes32 [] votantes;

    // Función para presentarse a las elecciones
    function Presentar_candidato(string memory _candidato, string memory _id) public{

        // Hash con los datos del candidato
        bytes32 hashCandidato = keccak256(abi.encodePacked(_id));

        // Verificamos si el candidato ya se ha presentado
        for(uint i= 0; i<candidatos.length;i++){
            require(keccak256(abi.encodePacked(candidatos[i])) != keccak256(abi.encodePacked(_candidato)), "Ya te has presentado a la votación.");
        }

        // Almacenar el hash de los datos del candidato ligados a su nombre
        ID_candidato[_candidato] = hashCandidato;

        // Almacenar el nombre del candidato
        candidatos.push(_candidato);

    }

    // Función que devuelve la lista de candidatos
    function Ver_candidatos() public view returns(string [] memory){
        //Devuelve la lista de los candidatos presentados
        return candidatos;
    }

    // Función que permite votar a un candidato
    function Votar(string memory _candidato) public{
        //Hash de la direccion de la persona que ejecuta esta funcion
        bytes32 votante = keccak256(abi.encodePacked(msg.sender));
        // Verificamos si el votante ya ha votado
        for(uint i= 0; i<votantes.length;i++){
            require(votantes[i] != votante, "Ya has votado.");
        }
        // Añadimos el voto al candidato
        votos_candidato[_candidato]++;
        // Aññadimos el hash del votante a la lista de votantes
        votantes.push(votante);
    }

    // Función que dado el nombre de un candidato nos devuelve el número de votos
    function VerVotos(string memory _candidato) public view returns(uint){
        // Devuelve el número de votos de un candidato
        return votos_candidato[_candidato];
    }

    //Funcion auxiliar que transforma un uint a un string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // Función que nos permite visualizar los candidatos con sus respectivos votos
    function verResultados() public view returns(string memory){
        // Guardamos en un string los candidatos con sus votos
        string memory resultados;
        //Recorremos el array de candidatos para actualizar el string resultados
        for(uint i = 0; i<candidatos.length; i++){
            //Actualizamos el string resultados y añadimos el candidato que ocupa la posicion "i" del array candidatos
            //y su numero de votos
            resultados = string(abi.encodePacked(resultados, "(", candidatos[i],", ",
            uint2str(VerVotos(candidatos[i])), ") ----- "));
        }
        //Devolvemos los resultados
        return resultados;
    }

    //Proporcionar el nombre del candidato ganador
    function Ganador() public view returns(string memory){
        //La variable ganador contendra el nombre del candidato ganador 
        string memory ganador = candidatos[0];
        // La variable empate nos sirver para el caso de empate entre candidatos
        bool empate = false;

        //Recorremos el array de candidatos para determinar el candidato con un numero de votos mayor
        for(uint i = 1; i<candidatos.length;i++){

            // Comprobamos si el nuevo canditato tiene mas votos que el ganador
            if(VerVotos(ganador) < VerVotos(candidatos[i])){
                ganador = candidatos[i];
                empate = false;
            // Miramos si hay empate entre los candidatos
            }else if(VerVotos(ganador) == VerVotos(candidatos[i])){
                empate = true;
            }
        }
        // En el caso de que haya empate modificamos el mensaje
        if(empate){
            ganador = "¡Hay un empate entre los candidatos!";
        }

        return string(abi.encodePacked("El ganador es: ",ganador));
    }
}