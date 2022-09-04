import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
//import { DaprClient, HttpMethod } from "@dapr/dapr"; 
//import { AcControllerCommand } from './ac-controller-command';

@Injectable({
  providedIn: 'root'
})
export class HomeApiService {

  private daprHost = "http://127.0.0.1";
  private daprPort = "3500"; 
  private serviceAppId = "home-api";
  private serviceMethod = "home";

  httpOptions = {
    headers: new HttpHeaders({ 
      'Content-Type': 'application/json',
      'dapr-app-id': this.serviceAppId 
    })
  };

  constructor(private http: HttpClient) { 
  }

  //constructor() { }

  async get(){

    const url = `${this.daprHost}:${this.daprPort}/home`;
    var response = this.http.get(url,this.httpOptions);

    console.log(response);
    return response;
    
    // var client = new DaprClient(this.daprHost, this.daprPort); 
    // var response = await client.invoker.invoke(this.serviceAppId , this.serviceMethod , HttpMethod.GET);
    
    // console.log(response);
    // return response;
    return {};
  }

  // set(command: AcControllerCommand): any {
  //   const url = `${this.urlPrefix}/api/ac/control`
  //   return this.http.post(url, command, this.httpOptions);
  // }
}
