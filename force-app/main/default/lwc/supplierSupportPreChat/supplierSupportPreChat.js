import BasePrechat from 'lightningsnapin/basePrechat';
import { api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import SLDS from '@salesforce/resourceUrl/SLDS';
// import CoupaSupplierPortalLogo from '@salesforce/resourceUrl/CoupaSupplierPortalLogo';
// import startChatLabel from '@salesforce/label/c.StartChat';

export default class Prechat extends BasePrechat {
    @api prechatFields;
    backgroundImgURL;
    @track fields;
    @track namelist;
    startChatLabel;

    /**
     * Set the button label and prepare the prechat fields to be shown in the form.
     */
    connectedCallback() {
        // console.log('CoupaSupplierPortalLogo', CoupaSupplierPortalLogo);
        // this.backgroundImgURL = CoupaSupplierPortalLogo;
        // this.startChatLabel = startChatLabel;
        this.startChatLabel = 'Start Chat';
        console.log('this.prechatFields', JSON.parse(JSON.stringify(this.prechatFields)));
        this.fields = this.prechatFields.map(field => {
            const { label, name, value, required, maxLength } = field;
            let isTypeInputSplitName = field.type == "inputSplitName";
            return { label, value, name, required, maxLength, isTypeInputSplitName };
        });
        this.namelist = this.fields.map(field => field.name);
    }

    /**
     * Focus on the first input after this component renders.
     */
    renderedCallback() {
        // Promise.all([
        //     loadStyle( this, SLDS )
        //     ]).then(() => {
        //         console.log( 'Files loaded' );
        //     })
        //     .catch(error => {
        //         console.log( error.body.message );
        // });
        this.template.querySelector("lightning-input").focus();
    }

    /**
     * On clicking the 'Start Chatting' button, send a chat request.
     */
    handleStartChat() {
        this.template.querySelectorAll("lightning-input").forEach(input => {
            // console.log('input name', input.name);
            // if (input.name == "Contact_Us_Topic__c" && input.value == "Test") {
            // }
            this.fields[this.namelist.indexOf(input.name)].value = input.value;
        });
        if (this.validateFields(this.fields).valid) {
            this.startChat(this.fields);
        } else {
            // Error handling if fields do not pass validation.
        }
    }
}