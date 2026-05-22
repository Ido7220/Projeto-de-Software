import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from "@angular/router";

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [RouterLink, FormsModule],
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {
  dadosLogin = {
    email: '',
    senha: '',
    tipoUsuario: 'USUARIO'
  };

  aoLogar() {
    console.log('Dados enviados para a API REST Java:', this.dadosLogin);
}

}

