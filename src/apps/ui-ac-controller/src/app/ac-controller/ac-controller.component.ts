import { Component, OnInit } from '@angular/core';
import { HomeApiService } from '../home-api.service';

@Component({
  selector: 'app-ac-controller',
  templateUrl: './ac-controller.component.html',
  styleUrls: ['./ac-controller.component.css']
})
export class AcControllerComponent implements OnInit {

  constructor(private homeService: HomeApiService) { }

  ngOnInit(): void {
    this.homeService.get();
  }

}
