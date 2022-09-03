import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AcControllerComponent } from './ac-controller/ac-controller.component';
import { ConfigurationComponent } from './configuration/configuration.component';

const routes: Routes = [
  { path: '', component: AcControllerComponent},
  { path: 'configuration', component: ConfigurationComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
