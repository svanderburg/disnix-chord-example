{
  ports = {
    ChordBootstrapNode = 8001;
    ChordNode1 = 8002;
    ChordNode2 = 8001;
    ChordNode3 = 8002;
  };
  portConfiguration = {
    targetConfigs = {
      test1 = {
        lastPort = 8002;
        minPort = 8000;
        maxPort = 9000;
        servicesToPorts = {
          ChordBootstrapNode = 8001;
          ChordNode1 = 8002;
        };
      };
      test2 = {
        lastPort = 8002;
        minPort = 8000;
        maxPort = 9000;
        servicesToPorts = {
          ChordNode2 = 8001;
          ChordNode3 = 8002;
        };
      };
    };
  };
}
